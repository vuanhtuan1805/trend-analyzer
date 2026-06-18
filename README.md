# journaltrendanalyzer

A new Flutter project.

## Code quality with SonarQube

This project includes SonarQube analysis configuration in `sonar-project.properties`
and a GitHub Actions workflow in `.github/workflows/sonarqube.yml`.

### Local scan

1. Create a project in SonarQube with the project key `journaltrendanalyzer`.
2. Generate a project analysis token in SonarQube.
3. Install the SonarScanner CLI and make sure `sonar-scanner` is available on
   your `PATH`.
4. Run the Flutter checks and coverage:

   ```sh
   flutter pub get
   flutter analyze
   flutter test --coverage
   ```

5. Run the scan:

   ```sh
   sonar-scanner \
     -Dsonar.host.url=http://localhost:9000 \
     -Dsonar.token=YOUR_TOKEN
   ```

   On Windows PowerShell:

   ```powershell
   sonar-scanner `
     -Dsonar.host.url=http://localhost:9000 `
     -Dsonar.token=YOUR_TOKEN
   ```

### GitHub Actions setup

1. In SonarQube, create or import the `journaltrendanalyzer` project.
2. Generate a project analysis token.
3. In GitHub, add a repository secret named `SONAR_TOKEN` with that token.
4. In GitHub, add a repository or organization variable named
   `SONAR_HOST_URL` with your SonarQube URL, for example
   `https://sonarqube.example.com`.
5. Push to `main` or open a pull request. The workflow will run
   `flutter analyze`, `flutter test --coverage`, and the SonarQube scan.

If your default branch is not `main`, update the branch name in
`.github/workflows/sonarqube.yml`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
