require 'sqlite3'

class DBKeeper

  def initialize
    @db = SQLite3::Database.new(File.expand_path('../../../db/chocolate.db', __FILE__))

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

  def close
    @db.close unless @db.closed?
  end

  # @param [FwrsModel]
  def create(type, name, master_id, active, as_task, notice_date)
      sql = 'INSERT INTO observations (type, master_id, name, active, as_task, notice_date) VALUES (?, ?, ?, ?, ?, ?)'
      return execute(sql, type, master_id, name, active, as_task, notice_date)
  end

  def update(id, name, notice_date)
    row = find(id).shift

      if !row.nil? && row['type'] == 'user'
        if !name.nil? && !notice_date.nil?
          sql ='UPDATE observations SET name = ?, notice_date = ? WHERE id = ?'
          return execute(sql, name, notice_date, id)
        elsif !name.nil?
          sql = 'UPDATE observations SET name = ? WHERE id = ?'
          return execute(sql, name, id)
        elsif !notice_date.nil?
          sql = 'UPDATE observations SET notice_date = ? WHERE id = ?'
          return execute(sql, notice_date, id)
        end
      else
        return :error
      end
  end

  def update_master(id, name, notice_date)
    row = find(id).shift

    if !row.nil?
        sql ='UPDATE observations SET name = ?, notice_date = ? WHERE id = ?'
        return execute(sql, name, notice_date, id)
    else
      return :error
    end
  end

  def delete(id)
    sql = 'DELETE FROM observations WHERE id = ?'
    return execute(sql, id)
  end

  def update_active(id, active)
    unless active == 1 || active == 0
      raise 'active value is "1" or "0" only'
    end
    sql = 'UPDATE observations SET active = ? WHERE id = ?'
    return execute(sql, active, id)
  end

  def update_as_task(id, as_task)
    unless as_task == 1 || as_task == 0
      raise 'as_task value is "1" or "0" only'
    end
    sql = 'UPDATE observations SET as_task = ? WHERE id = ?'
    return execute(sql, as_task, id)
  end

  def find_by_master_id(master_id)
    sql = 'SELECT * FROM observations WHERE master_id = ?'
    return execute(sql, master_id)
  end

  # Finds notifiable events
  # Range: between [current-time] and [current-time + 10 second]
  def find_events
    from = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S')
    to = DateTime.parse((Time.now + 10000).to_s).strftime('%Y-%m-%d %H:%M:%S')
    sql = "SELECT * FROM observations WHERE notice_date BETWEEN '#{from}' AND '#{to}'"
    return execute(sql)
  end

  def find(type)
    if type == :all
      sql = 'SELECT * FROM observations'
      return execute(sql)
    elsif type == :notice_date
      sql = 'SELECT * FROM observations ORDER BY notice_date'
      return execute(sql)
    else
      sql = 'SELECT * FROM observations WHERE id = ?'
      return execute(sql, type)
    end
  end

  def delete_old
    now = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S')
    sql = 'DELETE FROM observations WHERE notice_date <= ?'
    return execute(sql, now)
  end

  private

  def execute(sql, *args)
    begin
      ps = @db.prepare(sql)
      ps.bind_params *args unless args.empty?
      res = ps.execute
      rows = []
      while row = res.next_hash
        rows << row
      end
    rescue => e
      raise(e)
    ensure
      ps.close
    end

    return rows
  end

end