def call(String name){
    echo "Hello ${name}"
}


def map(Map config = [:]){
    echo "Hello ${config.name}, ${config.value}"
}