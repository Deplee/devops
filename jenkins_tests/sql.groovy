import java.sql.*;
import groovy.sql.Sql
import groovy.json.JsonSlurper

/*class Database {
   static void main(String[] args) {
      // Creating a connection to the database
      def sql = Sql.newInstance('jdbc:mysql://192.168.0.12:5555/testdb','root',
      '12345', 'org.mariadb.jdbc.Driver')
      // Executing the query SELECT VERSION which gets the version of the database
      // Also using the eachROW method to fetch the result from the database
sql.eachRow('select * from table1'){
tp ->
println([tp.field1,tp.field2,tp.field3])
}
      sql.close()
   }
}*/

class Database{
   static void main(String[] args){
   def JsonSlurper = new JsonSlurper()
   def config = JsonSlurper.parse(new File('config.json'))
String PCName, MAC, WiFi, Bluetooth, Manufacturer, MarkModel, SerialNumber, Bitlocker, RamSize, DiskType, DiskSize, DiskFreeSpace, DiskPercentUsedSpace, OSVersion, strDiskType, strDiskSize, strDiskFreeSpace, strDiskUsedSpace
String OSInstallDate

   PCName = "$config.arm_info.PCName"
   MAC = "$config.arm_info.MAC"
   WiFi = "$config.arm_info.WiFi"
   Bluetooth = "$config.arm_info.Bluetooth"
   Manufacturer = "$config.arm_info.Manufacturer"
   MarkModel = "$config.arm_info.MarkModel"
   SerialNumber = "$config.arm_info.SerialNumber"
   Bitlocker = "$config.arm_info.Bitlocker"
   RamSize = "$config.arm_info.RamSize"

   strDiskType = "$config.arm_info.DiskInfo.Type"
   strDiskSize = "$config.arm_info.DiskInfo.Size"
   strDiskFreeSpace = "$config.arm_info.DiskInfo.Free"
   strDiskUsedSpace = "$config.arm_info.DiskInfo.Used"

   DiskType = strDiskType.replaceAll("[^a-zA-Z-0-9]", "")
   DiskSize = strDiskSize.replaceAll("[^a-zA-Z-0-9]", "")
   DiskFreeSpace = strDiskFreeSpace.replaceAll("[^a-zA-Z-0-9]", "")
   DiskPercentUsedSpace = strDiskUsedSpace.replaceAll("[^a-zA-Z-0-9]", "")

   OSVersion = "$config.os_info.OSVersion"
   OSInstallDate = "$config.os_info.OSInstallDate"

   def sql = Sql.newInstance('jdbc:mysql://localhost:5555/inventorization',
                              'root', '12345', 'org.mariadb.jdbc.Driver')
   sql.connection.autoCommit = false
   def sqlstring = """INSERT INTO inventorization (PCName,
                      MAC, WiFi, Bluetooth, Manufacturer, SerialNumber, RamSize,
                      DiskType, DiskSize, DiskFreeSpace, DiskPercentUsedSpace, OSVersion, OSInstallDate)
                     VALUES ($PCName,
                      $MAC, $WiFi, $Bluetooth, $Manufacturer, $SerialNumber, $RamSize,
                      $DiskType, $DiskSize, $DiskFreeSpace, $DiskPercentUsedSpace, $OSVersion, $OSInstallDate) """
try {
   sql.execute(sqlstring)
   sql.commit()
   println "[LOG]. Commit Succeed."
} catch (Exception ex) {
   sql.rollback()
   println "[ERROR]. Exception."
   }
   sql.close()
      }
   }
