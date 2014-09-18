require 'sqlite3'

class DBKeeper

  def initialize
    @db = SQLite3::Database.new('../db/chocolate.db')

    result = @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='observations'")
    if result.empty?
      sql = <<-SQL
CREATE TABLE observations (
id INTEGER PRIMARY KEY AUTOINCREMENT,
type TEXT,
master_id TEXT,
name TEXT,
active INTEGER,
as_task INTEGER,
notice_date TEXT
);
      SQL
      @db.execute(sql)
    end
  end

  # @param [FwrsModel]
  def create(type, name, master_id, active, as_task, notice_date)
    begin
      ps = @db.prepare("INSERT INTO observations (type, master_id, name, active, as_task, notice_date) VALUES (?, ?, ?, ?, ?, ?)")
      ps.bind_params(type, master_id, name, active, as_task, notice_date)
      return ps.execute
    rescue => e
      puts e
    end
  end

  def update(id, name, notice_date)
    begin
      ps = @db.prepare("UPDATE observations SET name = ?, notice_date = ? WHERE id = ?")
      ps.bind_params(name, notice_date, id)
      return ps.execute
    rescue => e
      puts e
    end
  end

  def delete(id)
    begin
      ps = @db.prepare("DELETE FROM observations WHERE id = ?")
      ps.bind_params(id)
      return ps.execute
    rescue => e
      puts e
    end
  end

  def update_active(id, active)
    begin
      if !(active == 1 || active == 0)
        raise 'active value is "1" or "0" only'
      end

      ps = @db.prepare("UPDATE observations SET active = ? WHERE id = ?")
      ps.bind_params(active, id)
      return ps.execute
    rescue => e
      puts e
    end
  end

  def update_as_task(id, as_task)
    begin
      if !(as_task == 1 || as_task == 0)
        raise 'as_task value is "1" or "0" only'
      end

      ps = @db.prepare("UPDATE observations SET as_task = ? WHERE id = ?")
      ps.bind_params(as_task, id)
      return ps.execute
    rescue => e
      puts e
    end
  end

  def find_by_master_id(master_id)
    begin
      ps = @db.prepare("SELECT * FROM observations WHERE master_id = ?")
      ps.bind_params(master_id)
      return ps.execute
    rescue => e
      puts e
    end
  end

  def find(type)
    begin
      if type == :all
        ps = @db.prepare("SELECT * FROM observations")
      elsif type == :notice_date
        ps = @db.prepare("SELECT * FROM observations ORDER BY notice_date")
      end
      return ps.execute
    rescue => e
      puts e
    end
  end

  def delete_old
    now = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S')
    begin
      ps = @db.prepare("DELETE FROM observations WHERE notice_date <= ?")
      ps.bind_params(now)
      return ps.execute
    rescue => e
      puts e
    end
  end

end