/*class Car {
    int carId
    String carNameex, carColor


    def setcarInfo(int id, String name,color){
        println "Id: $id, Name: $name, Color: $color"
    }
static void main(args){
    def Honda = new Car(carId: 1, carNameex: "X-trail", carColor: "Blue")
    println "$Honda.carId, $Honda.carNameex, $Honda.carColor"
}

}
*/


//println "Example 2"


class Student {
    String fname
    int age

    def setfname(String firstname){
    fname = firstname
}
    def setage(int vozr){
    age = vozr
}
    def getInfo(){
    println ("fname: $fname")
}

static void main(args){

Student stud1 = new Student()
stud1.setfname("Bob")
stud1.getInfo()
}

}
