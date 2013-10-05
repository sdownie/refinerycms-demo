class RemoveMetaKeywordsFromSeoMeta < ActiveRecord::Migration
  def up
    with_index_name_fix do
      remove_column :seo_meta, :meta_keywords
    end
  end
 
  def down
    add_column :seo_meta, :meta_keywords, :string
  end
 
  def with_index_name_fix
    if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite" &&
        ActiveRecord::Base.connection.indexes('seo_meta').collect(&:name).include?("index_seo_meta_on_seo_meta_id_and_seo_meta_type")
      remove_index :seo_meta, :seo_meta_id_and_seo_meta_type
      yield
      add_index :seo_meta, [:seo_meta_id, :seo_meta_type], :name => :id_type_index_on_seo_meta
    else
      yield
    end
  end
end
