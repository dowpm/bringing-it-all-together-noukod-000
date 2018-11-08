class Dog
  attr_accessor :name, :breed, :id

  def initialize **attr
    @name, @breed, @id = attr[:name], attr[:breed], attr[:id]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY ,
      name TEXT, breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql,name,breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create name:, breed:
    dog = new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id id
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    new(*DB[:conn].execute(sql,id)[0])
  end

end
