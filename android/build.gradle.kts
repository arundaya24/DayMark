allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid: () -> Unit = {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            val m1 = androidExt.javaClass.methods.firstOrNull { it.name == "compileSdkVersion" && it.parameterCount == 1 }
            if (m1 != null) {
                try {
                    m1.invoke(androidExt, 36)
                } catch (_: Throwable) {
                    try {
                        m1.invoke(androidExt, "android-36")
                    } catch (_: Throwable) {}
                }
            }
            val m2 = androidExt.javaClass.methods.firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
            if (m2 != null) {
                try {
                    m2.invoke(androidExt, 36)
                } catch (_: Throwable) {}
            }
        }
    }

    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate {
            configureAndroid()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
