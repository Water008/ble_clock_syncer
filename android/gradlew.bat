@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Gradle startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

@rem Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xMe_args
:win9xMe_args
shift
:setupArgs
if "%1"=="" goto doneStart
set _SCROLL_SHIFT=0
set _PASS_SHIFT=0
:copyParams
set "_PASS_PARAMS_"
set _PARAM=%1
shift
if not "%_PARAM%"=="" goto paramLoop
:paramLoop
set "_PASS_PARAMS_=%_PASS_PARAMS% %_PARAM%"
if "%_PARAM%"=="" goto paramEmpty
set "_PASS_PARAMS_=%_PASS_PARAMS%"%
shift
goto copyParams

:paramEmpty
set "_PASS_PARAMS_%_PASS_SHIFT%=%_PASS_PARAMS%"
set /a _PASS_SHIFT+=1
if "%_PASS_SHIFT%"=="0" goto paramLoop
set _PASS_PARAMS=
goto copyParams

:doneStart
rem This label allows us to use goto with the SHIFT command to cycle through all command line args

set _OPTS=
set _OPTS=%1%
set _PARAMS=
set _ARGS=

:parse_loop
if "%~1"=="" goto parse_done
rem 前移参数处理
if "%~1"=="--help" (
    echo.
    echo Gradle启动脚本
    echo.
    echo 使用方法: gradlew [options] [tasks]
    echo.
    echo 常用任务:
    echo   gradlew assembleDebug      - 构建Debug APK
    echo   gradlew assembleRelease    - 构建Release APK
    echo.
    echo 选项:
    echo   --help                    - 显示此帮助信息
    echo.
    goto end
)
set _ARGS=%_ARGS% %1%
shift
goto parse_loop

:parse_done

set _OPTS=
set _ARGS=

:execute
rem 在不支持的 Windows 版本上，不要执行
set APP_HOME=%APP_HOME:"=%
set APP_BASE_NAME=%APP_BASE_NAME:Gradle

@rem 初始化classpath
set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar

@rem 执行 Gradle
set _OPTS=
set JAVA_EXE=%JAVA_HOME%\bin\java.exe
set DEFAULT_JVM_OPTS=
set GRADLE_OPTS="-Dorg.gradle.app.name=%APP_BASE_NAME%" "-Dorg.gradle.jvmargs=-Xmx1536m"

"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %_ARGS%

:end
if "%ERRORLEVEL%"=="0" goto :eof

:fail
exit /b 1
