@Library("rocket-notify-lib") _

def nuget_config_path = "C:/ProgramData/NuGet/NuGet.Config"

def dotnet = "\"C:/Program Files/dotnet/dotnet.exe\""

def msbuild = "\"C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/MSBuild/Current/Bin/MSBuild.exe\""

def projects = [
        Pinery                  : [src_path : "", solution_name : "", "sfproj_path" : "", "sfproj_name" : ""],
        Prj                     : [src_path : "", solution_name : "", "sfproj_path" : "", "sfproj_name" : ""],
        Public_Relations        : [src_path : "", solution_name : "", "sfproj_path" : "", "sfproj_name" : ""],
        Tech_Support_Api        : [src_path : "", solution_name : "", "sfproj_path" : "", "sfproj_name" : ""],
]

def nuget_steps = [
        "Nuget Restore *"                  : [],
        "Nuget Restore *"                     : [],
        "Nuget Restore *"        : [],
        "Nuget Restore *"        : []
]

def build_steps = [
        "Build Project *"                          : [],
        "Build Project *"                             : [],
        "Build Project *"                : [],
        "Build Project *"                : []
]
def package_application_steps = [
        "Package Application *"                    : [],
        "Package Application *"                       : [],
        "Package Application *"          : [],
        "Package Application *"          : []
]

def unit_tests_steps = [
        "RUN NUnit tests *"                          : [],
        "RUN NUnit tests *"                             : [],
        "RUN NUnit tests *"                : []
]

def unit_test_config = [
        db_name         : "*-${BUILD_NUMBER}",
        sql_server      : "",
        sql_instance    : "",
        sql_user        : "",
        sql_pass        : "",
        acc_file        : ""
]

def startDate = new Date()

properties([
        gitLabConnection(
                gitLabConnection: 'GitLab',
                jobCredentialId: ''
        ),
        durabilityHint('PERFORMANCE_OPTIMIZED'),
        buildDiscarder(
                logRotator(
                        artifactDaysToKeepStr: '',
                        artifactNumToKeepStr: '',
                        daysToKeepStr: '',
                        numToKeepStr: '20'
                )
        ),
        parameters([
                gitParameter(
                        branch: 'main',
                        branchFilter: 'origin/(.*)',
                        defaultValue: '',
                        listSize: '10',
                        name: 'BRANCH',
                        quickFilterEnabled: true,
                        requiredParameter: true,
                        selectedValue: 'NONE',
                        sortMode: 'NONE',
                        tagFilter: '*',
                        type: 'GitParameterDefinition',
                        useRepository: '.*.git'),
                booleanParam(
                        defaultValue: false,
                        description: 'RUN unit tests',
                        name: 'RUN_UNIT_TESTS'
                ),
                booleanParam(
                        defaultValue: true,
                        description: 'sleep a minute',
                        name: 'SLEEP'
                ),
                choice(choices: [
                        'Testing',
                        'Debugging',
                        'Stagin',
                        'Release'
                ],
                        description: "",
                        name: "BUILD_CONF"),
                [
                        $class      : 'WHideParameterDefinition',
                        defaultValue: 'jenkins',
                        name        : 'INFRASTRUCTURE_BRANCH'
                ],
                [
                        $class      : 'WHideParameterDefinition',
                        defaultValue: 'RU',
                        name        : 'COUNTRY'
                ],
                [
                        $class      : 'WHideParameterDefinition',
                        defaultValue: '#*',
                        name        : 'channel'
                ]
        ])
])
String[] full_branch_name;
full_branch_name = env.BRANCH.split('/');
branch_name = full_branch_name.last()
full_env_name = "${env.COUNTRY}_${env.PRODUCT_NAME}_${env.ENV_NAME}"

timestamps {
        ansiColor('xterm') {
                node("*") {
                        try {
                        stage('Clone repositories') {
                                println('BEGIN SECTION Clone repositories')
                                println("-----")
                                println("----> Clone backend")
                                println("-----")
                                git branch: env.BRANCH, credentialsId: 'gitlab_gituser', url: '*'

                                println("-----")
                                println('----> Clone infrastructure')
                                println("-----")
                                dir('infrastructure') {
                                        git branch: env.INFRASTRUCTURE_BRANCH, credentialsId: 'gitlab_gituser', url: '*'
                                        pwsh returnStdout: true, script: '''
                        $InfraBranchWork = "''' + env.INFRASTRUCTURE_BRANCH + '''"
                        $InfraBranchSwitch = "''' + branch_name + '''"
                        function SetInfrastructureBranch {
                            git remote update origin --prune
                            git fetch
                            if ($InfraBranchSwitch -notlike "main"){
                              $IsInfrastructureBranchExists = git branch -a --remote | Select-String $InfraBranchSwitch
                              if ($IsInfrastructureBranchExists) {
                                  Write-Host $IsInfrastructureBranchExists
                                  $InfraBranchWork = ($IsInfrastructureBranchExists -split "/")[-1]
                                  write-host "===`nSetting up new Infrastructure branch to $InfraBranchWork.`n==="
                              }
                            }
                            git checkout .
                            git switch $InfraBranchWork
                            $CurrentBranchName = git rev-parse --abbrev-ref HEAD
                            Write-Host "Current branch is: $CurrentBranchName"
                            git clean -fdx
                            git reset --hard HEAD^
                            git pull origin $InfraBranchWork
                        }
                        SetInfrastructureBranch
                        '''
                                }
                                println("End of Stage")
                        }

                        stage("NuGet restore and .Net Restore'"){
                                println('BEGIN SECTION NuGet and .Net Restore')
                                println("-----")
                                println("----> NuGet restore and .Net Restore")
                                println("-----")
                                projects.each{project_hashmap_value  ->
                                        nuget_tool_path = tool name: 'nuget-6.2.1', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
                                        println("${nuget_tool_path}\\nuget.exe restore ${project_hashmap_value.value.src_path}/${project_hashmap_value.value.solution_name}.sln -configfile ${nuget_config_path}")
                                        bat script: "${nuget_tool_path}\\nuget.exe restore ${project_hashmap_value.value.src_path}/${project_hashmap_value.value.solution_name}.sln -configfile ${nuget_config_path}"
                                }
                                println("End of Stage")
                        }

                        stage('Generate and set unique DB name for sql tests'){
                                println('BEGIN SECTION Generate and set unique DB name for sql tests')
                                if (env.RUN_UNIT_TESTS == 'true'){
                                        pwsh script: """
                                        Write-Host "======`nNew DB name is: ${unit_test_config.db_name}`n======"
                                        \$connectionString = "data source = ${unit_test_config.sql_server}\\${unit_test_config.sql_instance}; initial catalog = ${unit_test_config.db_name}; persist security info = True; user id = ${unit_test_config.sql_user}; password = ${unit_test_config.sql_pass};MultipleActiveResultSets=True;App=EntityFramework"
                                        [xml]\$AccSqlConfig = Get-Content "${unit_test_config.acc_file}"
                                        # \$AccSqlConfig.configuration.SqlUnitTesting.ExecutionContext.connectionString = \$connectionString
                                        # \$AccSqlConfig.configuration.SqlUnitTesting.PrivilegedContext.connectionString = \$connectionString
                                         \$AccSqlConfig.configuration.connectionStrings.add.connectionString = \$connectionString
                                         \$AccSqlConfig.Save("${unit_test_config.acc_file}")
                                         Get-Content ${unit_test_config.acc_file}
                                 """
                                }
                                println("End of Stage")
                        }

                       stage("Build Project"){
                               println('BEGIN SECTION Build Project')
                               println("-----")
                               println("----> Build Project")
                               println("-----")
                               projects.each{project_hashmap_value ->
                                       println("${msbuild} ${project_hashmap_value.value.src_path}/${project_hashmap_value.value.solution_name}.sln /t:Rebuild /p:Configuration=${env.BUILD_CONF} /m /p:BuildInParallel=true /p:Platform=x64")
                                       bat script: "${msbuild} ${project_hashmap_value.value.src_path}/${project_hashmap_value.value.solution_name}.sln /t:Rebuild /p:Configuration=${env.BUILD_CONF} /m /p:BuildInParallel=true /p:Platform=x64"
                               }
                               println("End of Stage")
                       }
                       stage("Package Application"){
                               println('BEGIN SECTION Package Application')
                               println("-----")
                               println("----> Package Application")
                               println("-----")
                               projects.each{project_hashmap_value ->
                                       println("${msbuild} ${project_hashmap_value.value.src_path}/${project_hashmap_value.value.sfproj_path}/${project_hashmap_value.value.sfproj_name}.sfproj /t:Package /p:Configuration=${env.BUILD_CONF} /m /p:BuildInParallel=true /p:Platform=x64")
                                       bat script: "${msbuild} ${project_hashmap_value.value.src_path}/${project_hashmap_value.value.sfproj_path}/${project_hashmap_value.value.sfproj_name}.sfproj /t:Package /p:Configuration=${env.BUILD_CONF} /m /p:BuildInParallel=true /p:Platform=x64"
                               }
                               println("End of Stage")
                       }
                        stage('Sleep a minute') {
                                println('BEGIN SECTION Sleep a minute')
                                if (env.SLEEP == 'true'){
                                        pwsh script: """
                                        Restart-Service RdlcReportingService
                                        Start-Sleep -Seconds 60
                                        """
                                }
                                println("End of Stage")
                        }
                        stage ("Run NUnit Tests"){
                                println('BEGIN SECTION Run NUnit Tests')
                                println("-----")
                                println("----> Run NUnit Tests")
                                println("-----")
                                projects.each{project_hashmap_name,project_hashmap_value ->
                                        if (env.RUN_UNIT_TESTS == 'true' && "${project_hashmap_name}" != "Tech_Support_Api") {
                                                println("${dotnet} test ${project_hashmap_value.src_path}/${project_hashmap_value.solution_name}.sln --configuration ${env.BUILD_CONF} --no-build")
                                                bat script: "${dotnet} test ${project_hashmap_value.src_path}/${project_hashmap_value.solution_name}.sln --configuration: ${env.BUILD_CONF} --no-build"
                                                println(". ./src/Pinery/Scripts/AccSqlTestsDropDB.ps1 -counter ${BUILD_NUMBER} -dbName ${unit_test_config.db_name} -sqlSrv ${unit_test_config.sql_server} -sqlInstance ${unit_test_config.sql_instance} -sqlUser ${unit_test_config.sql_user} -sqlPass ${unit_test_config.sql_pass}")
                                                bat script: "powershell -File ./src/Pinery/Scripts/AccSqlTestsDropDB.ps1 -counter ${BUILD_NUMBER} -dbName ${unit_test_config.db_name} -sqlSrv '${unit_test_config.sql_server}' -sqlInstance '${unit_test_config.sql_instance}' -sqlUser ${unit_test_config.sql_user} -sqlPass ${unit_test_config.sql_pass}"
                                        }
                                }
                                println("End of Stage")
                        }
                        stage('Kill MS Build'){
                                println('BEGIN SECTION Kill MS Build')
                                pwsh script: """
                                Stop-Process -Name MSBuild -Force
                                """
                                buildResult = 'SUCCESS'
                                println("End of Stage")
                                }
                        } catch (Exception ex) {
                                if (ex.toString() == "org.jenkinsci.plugins.workflow.steps.FlowInterruptedException") {
                                        buildResult = "CANCELED"
                                        return buildResult
                                } else {
                                        def exception_msg = ex.getMessage()
                                        buildResult = "FAILURE - ${exception_msg}"
                                        error('Error handled.')
                                        return buildResult
                                }
                        } finally {
                                def stopDate = new Date()
                                title = "Result of build: ${JOB_BASE_NAME} | ${env.BUILD_CONF} | ${env.BRANCH}"
                                text = "Number: *${BUILD_NUMBER}* \\n\\r Build Log: *[URL](${BUILD_URL}consoleFull)* \\n\\r Name: *${JOB_BASE_NAME}* \\n\\r Result: *${buildResult}* \\n\\r "
                                withCredentials([usernamePassword(credentialsId: 'rocket_notifier', passwordVariable: 'rocket_notifier_token', usernameVariable: 'rocket_notifier_id')]) {
                                        rocketLib.rocketNotify(buildResult,title,text,startDate,stopDate)
                                }
                        }
                }
        }
}
//note - add HIDE PARAM "CHANNEL"
