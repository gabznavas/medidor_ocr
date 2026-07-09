# Leitor de Medidor OCR

Aplicativo Flutter para fotografar um medidor (água, luz ou gás) e extrair automaticamente o número da leitura usando OCR local (offline), com opção de conferência e correção manual antes de confirmar.

## Funcionalidades

- Captura de foto via câmera do dispositivo
- Reconhecimento de texto/números via ML Kit (processamento 100% local, sem envio da imagem para servidores externos)
- Filtro automático que identifica o candidato mais provável a ser o número do medidor
- Campo editável para o usuário confirmar ou corrigir o número antes de salvar

## Tecnologias

- [Flutter](https://flutter.dev)
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) — OCR local via ML Kit
- [image_picker](https://pub.dev/packages/image_picker) — captura de imagem pela câmera

## Pré-requisitos

- Flutter SDK instalado ([guia oficial](https://docs.flutter.dev/get-started/install))
- Android SDK (`minSdkVersion 21` ou superior) e/ou Xcode configurado para iOS
- Dispositivo físico ou emulador com câmera funcional (emuladores sem câmera real podem ter limitações no teste)

## Instalação

Clone o repositório e instale as dependências:

```bash
git clone <url-do-repositorio>
cd medidor_ocr
flutter pub get
```

## Configuração de permissões

### Android

Em `android/app/src/main/AndroidManifest.xml`, adicione dentro da tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

Em `android/app/build.gradle`, confirme:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS

Em `ios/Runner/Info.plist`, adicione dentro do `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para fotografar o medidor</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos para ler o medidor</string>
```

## Executando o projeto

```bash
flutter run
```

## Como usar

1. Toque em **"Fotografar medidor"** para abrir a câmera
2. Tire a foto do visor do medidor, mantendo a câmera paralela e bem iluminada
3. O app processa a imagem localmente e sugere um número no campo de texto
4. Confira o número sugerido e corrija manualmente se necessário
5. Toque em **"Confirmar leitura"** para salvar

## Estrutura do reconhecimento

A lógica de extração (`_lerNumero`) percorre os blocos de texto reconhecidos, filtra apenas sequências numéricas com tamanho plausível para um medidor (4 a 9 dígitos) e retorna a sequência mais longa encontrada como melhor candidato. O usuário sempre pode ajustar o resultado manualmente.

## Limitações conhecidas

- Números em **letra cursiva** têm taxa de reconhecimento baixa; o OCR funciona melhor com texto impresso ou letra de forma separada — o que corresponde bem ao caso real de displays de medidores (rolete mecânico ou digital)
- Reflexos no vidro/plástico do visor, sujeira, ferrugem ou ângulo inadequado da foto podem reduzir a precisão
- O OCR é um auxílio, não uma fonte de verdade — a confirmação manual do número é sempre recomendada antes de usar o dado para fins de cobrança

## Melhorias futuras

- Adicionar um retângulo-guia na tela da câmera para orientar o enquadramento do visor do medidor
- Persistência local das leituras (ex.: `sqflite`)
- Associação de cada leitura a uma localização geográfica (ex.: integração com `flutter_map` ou `maplibre_gl`)
- Histórico de leituras por medidor/endereço
