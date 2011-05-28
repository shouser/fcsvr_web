class CreateFcsvrCmdHistories < ActiveRecord::Migration
  def self.up
    create_table :fcsvr_cmd_histories do |t|
      t.text :cmd_executed
      t.text :raw_response
      t.boolean :dry_run
      t.timestamps
    end
  end

  def self.down
    drop_table :fcsvr_cmd_histories
  end
end
