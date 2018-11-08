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
    id, name, breed = *DB[:conn].execute(sql,id)[0]
    new(id: id, name:name, breed:breed)
  end

  def self.find_or_create_by **attr
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    result = DB[:conn].execute(sql,attr[:name],attr[:breed])[0]

    if result
      id, name, breed = *result
      new(id:id, name:name, breed:breed)
    else
      create name:attr[:name], breed:attr[:breed]
    end
  end

end
