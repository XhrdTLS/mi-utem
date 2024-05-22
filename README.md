# Mi UTEM para Android e iOS
Aplicación multiplataforma hecha por estudiantes de la [Universidad Tecnológica Metropolitana de Chile](https://www.utem.cl/) enfocada en adaptar la [plataforma académica Mi.UTEM](https://mi.utem.cl/) de la institución a dispositivos móviles.

## Requisitos técnicos
- Flutter 3.7.12 (te recomendamos utilizar [fvm](https://fvm.app) para facilitar la administración de versiones)
- macOS + XCode (para compilar en iOS)
- Android Studio (para compilar en Android)
- ruby 3.3.0 (para compilar y subir app a App Store y Google Play)

## Organización de carpetas
```
|-- lib
|   |-- config (Configuración de la aplicación)
|   |-- controllers (Controladores de la aplicación, para procesar datos de una vista especifica)
|   |-- models (Modelos de datos)
|   |-- repositories (Repositorios de datos, para obtener datos desde la API)
|   |-- screens (Pantallas de la aplicación)
|   |-- services (Servicios de la aplicación, maneja y procesa los datos de repositorios)
|   |-- themes (Temas de la aplicación)
|   |-- utils (Utilidades de la aplicación)
|   |-- widgets (Widgets de la aplicación)
|-- main.dart (Punto de entrada de la aplicación)
|-- service_manager.dart (Registra los servicios de la aplicación)
```

### Construcción de la app

Para construir la app utilizamos fastlane.
Comienza revisando la documentación de Fastlane para [iOS](https://docs.fastlane.tools/getting-started/ios/setup/) y [Android](https://docs.fastlane.tools/getting-started/android/setup/).
Utilizaremos la instalación de bundler para instalar las dependencias y ejecutar fastlane.

<details>
<summary>Instalación de Bundler</summary>

(Se asume que tienes instalado Ruby 3.3.0 o superior)
```bash
gem install bundler
```
</details>

<details>
<summary>Instalación de las Dependencias</summary>

Una vez instalado ejecutarás este comando para instalar las dependencias:
```bash
bundle install
```
</details>

<details>
<summary>Subiendo una nueva Actualización</summary>

Para construir la app ejecuta este comando:
```bash
bundle exec fastlane upload type:"beta" skip_ios:false skip_android:false skip_clean:true skip_cocoapods:true skip_git_push:true skip_slack:true is_ci:true
```
Este comando subirá el archivo binario a AppStore y Google Play. Esto hacen las variables:
- `skip_ios`: Si es `true` no subirá la app a AppStore, si es `false` subirá la app a AppStore.
- `skip_android`: Si es `true` no subirá la app a Google Play, si es `false` subirá la app a Google Play.
- `skip_clean`: Si es `true` no limpiará los archivos temporales, si es `false` limpiará los archivos temporales (se recomienda utilizar para construcciones en producción y evitar problemas con archivos guardados en caché).
- `skip_cocoapods`: Si es `true` no instalará las dependencias de CocoaPods, si es `false` instalará las dependencias de CocoaPods (se recomienda utilizar para construcciones en producción y evitar problemas con dependencias de CocoaPods).
- `skip_git_push`: Si es `true` no creará una nueva etiqueta, si es `false` creará una nueva etiqueta con la lista de cambios formateada.
- `skip_slack`: Si es `true` no enviará un mensaje a Slack, si es `false` enviará un mensaje a Slack.
- `is_ci`: Si es `true` se ejecutará en modo de integración continua, es decir, no esperará a ver si la versión aparece en AppStore o Google Play, si es `false` esperará a ver si la versión aparece en AppStore o Google Play. Además, al ser `true` también evitará editar el repositorio de Match (el cual contiene los certificados de distribución de la app).
</details>

## Créditos
Este proyecto fue creado por el Club de Desarrollo Experimental (ExDev) de la Universidad Tecnológica Metropolitana y es mantenido por los propios estudiantes con el apoyo del equipo de SISEI. Mira los perfiles que han contribuido a este proyecto:

<a href="https://github.com/exdevutem/mi-utem/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=exdevutem/mi-utem" alt="Contribuidores"/>
</a>