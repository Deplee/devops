import groovy.json.JsonSlurper

def jsonSlurper = new JsonSlurper()

def config = jsonSlurper.parse(new File('config.json'))

kke = "$config.arm_info.DiskInfo.Used"

String c = kke
String b = c.replaceAll("[^a-zA-Z-0-9]","")
//println(c)
//println(c.split('[]')
println(b)
