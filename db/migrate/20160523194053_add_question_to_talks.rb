class AddQuestionToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :question, :string
  end
end
