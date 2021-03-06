require_relative( '../db/sql_runner' )

class Transaction

  attr_reader( :id )
  attr_accessor( :merchant_id, :transaction_date, :value, :tag_id )

  def initialize(options)
    @transaction_date = options['transaction_date']
    @merchant_id = options['merchant_id'].to_i
    @value = options['value']
    @tag_id = options['tag_id'].to_i
    @id = options['id'].to_i if options['id']
  end

  def save
    sql ="INSERT INTO transactions(
    transaction_date, merchant_id, value, tag_id
    ) VALUES ( $1, $2, $3, $4 ) RETURNING id"
    values = [@transaction_date, @merchant_id, (@value.to_f * 100).to_i, @tag_id]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def self.all
    sql = "SELECT * FROM transactions"
    transactions = SqlRunner.run(sql)
    return transactions.map {|transaction| Transaction.new(transaction)}
  end

  def self.delete(id)
    sql = "DELETE FROM transactions WHERE id = $1"
    values = [id]
    SqlRunner.run( sql, values )
  end

  def update()
    sql = "UPDATE transactions SET (
    transaction_date, merchant_id, value, tag_id )
    = ($1, $2, $3, $4) WHERE id = $5"
    values = [@transaction_date, @merchant_id, (@value.to_f * 100).to_i, @tag_id, @id]
    SqlRunner.run(sql, values)
  end

  def self.find( id )
    sql = "SELECT * FROM transactions
    WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values).first
    transaction = Transaction.new(result)
    return transaction
  end

  def merchant()
    merchant = Merchant.find(@merchant_id)
    return merchant
  end

  def tag()
    tag = Tag.find(@tag_id)
    return tag
  end

  def self.total()
    sql = "SELECT SUM(value)
    FROM transactions;"
    result = SqlRunner.run(sql).first["sum"].to_f/100
    return result.to_f
  end

end
