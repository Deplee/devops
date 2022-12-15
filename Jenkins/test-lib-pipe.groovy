@Library("my-shared-lib") _

node("Ubuntu Main"){
    stage("test-1"){
    println("STAGE #1")
        mapTest.map(test: "David", age: "32")
        mapTest.call("ivan")
    }
}