class SectionDocument
  include Mongoid::Document
  
  belongs_to_related :section
  
  before_destroy :delete_grid_file
  
  field :title
  field :media_type
  field :content_type
  field :file_id
  field :document_id
  field :link_info, :type => Array
  field :pedigree_info
  field :created_at, :type => DateTime
  field :last_modified, :type => DateTime
  #field :modifications, :type => Array
  field :confidentiality
  field :access_control
  field :consent

  def create_metadata_from_xml(node)
    ctx = NamespaceContext.new(node, 'md' => 'http://projecthdata.org/hdata/schemas/2009/11/metadata')
    self.title = ctx.first('/md:DocumentMetaData/md:Title').text
    self.document_id = ctx.first('/md:DocumentMetaData/md:DocumentId').text
    links = ctx.first('/md:DocumentMetaData/md:LinkedDocuments/md:Link/md:Target')
    if links
      self.link_info = links.map {|l| l.text}
    end
  end

  def create_document(content, filename, content_type)
    grid = Mongo::Grid.new(self.class.db)
    self.file_id = grid.put(content, :filename => filename, :content_type => content_type)
    self.save!
  end
  
  def grid_document
    grid = Mongo::Grid.new(self.class.db)
    grid.get(BSON::ObjectID.from_string(self.file_id))
  end
  
  def delete_grid_file
    grid = Mongo::Grid.new(self.class.db)
    grid.delete(BSON::ObjectID.from_string(self.file_id))
  end
  
  def replace_grid_file(content, filename, content_type)
    self.delete_grid_file
    self.create_document(content, filename, content_type)
  end
end

