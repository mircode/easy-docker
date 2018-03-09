# Parquet列式存储
https://www.cnblogs.com/lsx1993/p/6098657.html
https://wzktravel.github.io/2016/10/20/use-mongo-spark-connector/
http://blog.csdn.net/yijichangkong/article/details/47151977
https://docs.mongodb.com/spark-connector/master/scala-api/
http://www.jianshu.com/p/9144dcdc2277
http://www.aboutyun.com/thread-12392-1-1.html

http://blog.csdn.net/gdmzlhj1/article/details/50483557
https://stackoverflow.com/questions/31482798/save-spark-dataframe-to-hive-table-not-readable-because-parquet-not-a-sequence

# 实验
# Spark
./bin/spark-shell --packages org.mongodb.spark:mongo-spark-connector_2.11:2.2.1

# Mongo
val url="mongodb://local:27017/perftrace.analysis_day"
var mongo=spark
mongo.read.format("com.mongodb.spark.sql").options(Map("uri"-> url,"partitioner"->"MongoPaginateBySizePartitioner")).load().registerTempTable("mongo_analysis_day")
spark.sql("create table if not exists analysis_day(pt_user string,pt_service string,pt_code string,pt_ip string,pt_user_ip string,pt_date string,pt_count int) partitioned by (dir0 string)  stored as parquet");
spark.sql("insert into table analysis_day partition (dir0='201710') select pt_user,pt_service,pt_code,pt_ip,pt_user_ip,pt_date,pt_count from mongo_analysis_day where pt_date>='20171001' and pt_date<'20171101'");



# MongoDB		  
./bin/spark-shell \
--conf "spark.mongodb.input.uri=mongodb://local:27017/perftrace.analysis_day?readPreference=primaryPreferred" \
--conf "spark.mongodb.output.uri=mongodb://local:27017/perftrace.analysis_day" \
--packages org.mongodb.spark:mongo-spark-connector_2.11:2.2.1

# Hive
import org.apache.spark.sql.hive.HiveContext

val db=new HiveContext(sc)
db.sql("show tables").show();

# Hello
import com.mongodb.spark._
import org.bson.Document
MongoSpark.load(sc).take(10).foreach(println)



# Spark SQL
import org.apache.spark.sql.SQLContext
import com.mongodb.spark._
import com.mongodb.spark.config._
import com.mongodb.spark.sql._

val db=SQLContext.getOrCreate(sc)
val df=db.loadFromMongoDB(ReadConfig(Map("uri" -> "mongodb://local:27017/perftrace.analysis_day", "partitioner" -> "MongoShardedPartitioner")))
df.registerTempTable("analysis_day")
db.sql("select * from analysis_day limit 10").show();

# mongo to parquet
db.sql("select * from analysis_day limit 10").write.parquet("/analysis_day.parquet");
val test=db.read.parquet("/analysis_day.parquet")
test.registerTempTable("test");
db.sql("select * from test").show();

  
#  Read
val conf=ReadConfig(Map("database"->"perftrace","collection"->"analysis_day","partitioner"->"MongoShardedPartitioner"),Some(ReadConfig(sc)))
val rdd=MongoSpark.load(sc,conf)
println(rdd.first.toJson)

val rdd=sc.loadFromMongoDB(ReadConfig(Map("uri"->"mongodb://local:27017/perftrace.analysis_day","partitioner"-> "MongoShardedPartitioner")))
println(rdd.first.toJson)

# DataFrame
import org.apache.spark.sql.SQLContext
import com.mongodb.spark._
import com.mongodb.spark.config._
import com.mongodb.spark.sql._
import org.bson.Document

val db=SQLContext.getOrCreate(sc)
val df=db.loadFromMongoDB(ReadConfig(Map("uri" -> "mongodb://local:27017/perftrace.analysis_day", "partitioner" -> "MongoShardedPartitioner")))
df.filter(df("pt_count") > 100).show()

# 显式使用DataFrame和DataSet
case class Character(name: String, age: Int)
val sqlContext = SQLContext.getOrCreate(sc)
val df = sqlContext.loadFromMongoDB[Character](ReadConfig(Map("uri" -> "mongodb://local:27017/perftrace.analysis_day", "partitioner" -> "MongoShardedPartitioner")))
df.printSchema()
root
 |-- name: string (nullable = true)
 |-- age: integer (nullable = false)
val dataset = df.as[Character]

# 或从RDD转换为DataFrame或DataSet
val rdd = sc.loadFromMongoDB(ReadConfig(Map("uri" -> "mongodb://local:27017/perftrace.analysis_day", "partitioner" -> "MongoShardedPartitioner")))
val dfInferredSchema = rdd.toDF()
val dfExplicitSchema = rdd.toDF[Character]()
val ds = rdd.toDS[Character]()

# Write
import com.mongodb.spark._ 
import com.mongodb.spark.config._
import org.bson.Document

val sparkDocuments = sc.parallelize((1 to 10).map(i => Document.parse(s"{spark: $i}")))
sparkDocuments.saveToMongoDB(WriteConfig(Map("uri" -> "mongodb://local:27017/perftrace.analysis_day")))

val writeConfig = WriteConfig(Map("collection" -> "spark", "writeConcern.w" -> "majority"), Some(WriteConfig(sc)))
MongoSpark.save(sparkDocuments, writeConfig)

