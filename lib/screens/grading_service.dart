class GradingService {
  static final Map<String, double> studentGrades = {
    "Ali Ahmed": 18.0,
    "Soumaya Ait Mbark": 19.5,
    "Youssef Karim": 15.0,
  };

  static double assignGrade(String recognizedName) {
    return studentGrades[recognizedName] ?? 0.0; // Retourne 0 si le nom est inconnu
  }
}
