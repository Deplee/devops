#!/usr/bin/env groovy
/*def test = { c,g ->
println c
println g}
test(5*2,6*3) */


/*value = new File('C:\\Users\\19837606\\.vscode').eachFile {
    it.name="/.*json/"
    println it
}*/

/* dir path */
def path='//mnt//hdd//src//groovy'
import java.io.File
/*

/* files count
int files_counter = 0

counter = new File(path)
counter.eachFile {
    files_counter += 1
}

println ("Count of files: $files_counter")
*/
/* get extensions */

int extension_err = 0
int f = 0
def name = []
try {
def ex = new File(path).eachFile {
    file_info -> file_info.getName().split("\\.")[-1]
    def extension = file_info.getName().split("\\.")[-1]
        if (extension ==~ "png|rar|pdf|xlsx|xlx|doc|docx|pst") {
                extension_err ++
                //println (file_extension.getName())
                //println (file_extension)
                println (extension)
        } else if (extension ==~ "txt"){
            //assert(extension ==~ null)
            name.add(file_info.getName())//.split("\\.")[0])
            f++
    }
}
    if (extension_err > 0){
        prntln "[Error]. File with extensions is exists. Extension is: $extension"
        }
    for (int i=0 ; i < f ; i++){
        //println (name[i])
        String main_name = name[i]
        String result_name = '1_' + name[i] + '.bp'
        command = ["sh", "-c", "cp $main_name $result_name"]
        Runtime.getRuntime().exec((String[]) command.toArray())
    }
    /* Log File */
File file = new File("copy.log")
file.write "[LOG]. $f File(s) copied.\n"
    /* console output log */
println "[LOG]. $f File(s) copied"
println ("Count of err extensions: $extension_err")
if (extension_err > 0){
    prntln "[Error]. File with extensions is exists. Extension is: $extension"
    exit(1)
}
}catch (Exception ex){
    println "[ERROR]. Exception detected."
}

/* copy  windows

source = '//mnt//hdd//groovy//file_operations//test.txt'
target = '//mnt//hdd//groovy//file_operations//test.txt'
new AntBuilder().copy( file:"$source", tofile:"$target") */
