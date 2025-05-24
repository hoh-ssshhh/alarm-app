// プロジェクトレベルの build.gradle

plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'  // ← これを追加
}

allprojects {
    repositories {
        google()  // Googleのリポジトリを追加
        mavenCentral()
    }
    defaultConfig {
  // 省略...
  minSdkVersion 21 // Googleログインには21以上必要
}

}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

apply plugin: 'com.google.gms.google-services'  // ← これを追加

defaultConfig {
  // 省略...
  minSdkVersion 21 // Googleログインには21以上必要
}
