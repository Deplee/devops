import groovy.json.JsonSlurper

class JSONparser {
   static void main(String[] args) {
      def jsonSlurper = new JsonSlurper()
      def object = jsonSlurper.parseText('{ "PCName": "groovy"}')
      println(object.PCName);

   }
}
