class AcademicDepartment {
  const AcademicDepartment({
    required this.name,
    required this.courses,
  });

  final String name;
  final List<String> courses;
}

abstract final class AcademicProgramCatalog {
  static const departments = <AcademicDepartment>[
    AcademicDepartment(
      name: 'School of Allied Medical Sciences',
      courses: [
        'Bachelor of Science in Medical Laboratory Science (BSMLS)',
        'Bachelor of Science in Nursing (B.S.N.)',
      ],
    ),
    AcademicDepartment(
      name: 'School of Arts and Sciences',
      courses: [
        'Bachelor of Arts in Communication (BA Com)',
        'Bachelor of Arts in English Language Studies (BAELS)',
        'Bachelor of Arts in International Studies (ABIS)',
        'Bachelor of Arts in Journalism (BA Journ)',
        'Bachelor of Arts in Marketing Communication (BA MarCom)',
        'Bachelor of Arts in Philosophy (A.B.-PHILO.)',
        'Bachelor of Arts in Political Science (BA PoS)',
        'Bachelor of Library and Information Science (BLIS)',
        'Bachelor of Science in Biology (BS Bio)',
        'Bachelor of Science in Biology Major in Medical Biology '
            '(BS Bio-Medical)',
        'Bachelor of Science in Biology Major in Microbiology '
            '(BS Bio-Microbiology)',
        'Bachelor of Science in Psychology (BS Psych)',
      ],
    ),
    AcademicDepartment(
      name: 'School of Business and Management',
      courses: [
        'Bachelor of Science in Accountancy (B.S.A.)',
        'Bachelor of Science in Business Administration - '
            'Financial Management (BSBA-FM)',
        'Bachelor of Science in Business Administration - '
            'Human Resource Management (BSBA-HRM)',
        'Bachelor of Science in Business Administration - '
            'Marketing Management (BSBA-MM)',
        'Bachelor of Science in Business Administration - '
            'Operations Management (BSBA-OM)',
        'Bachelor of Science in Entrepreneurship (BS Entrep)',
        'Bachelor of Science in Hospitality Management (BSHM)',
        'Bachelor of Science in Hospitality Management - '
            'Food and Beverage (BSHM-F and B)',
        'Bachelor of Science in Management Accounting (B.S.M.A.)',
        'Bachelor of Science in Tourism Management (BSTM)',
      ],
    ),
    AcademicDepartment(
      name: 'School of Computer Studies',
      courses: [
        'Associate in Computer Technology (A.C.T.)',
        'Associate in Computer Technology with Specialization in '
            'Software Development (A.C.T.-S.D.)',
        'Bachelor of Science in Computer Science (B.S.C.S.)',
        'Bachelor of Science in Game Development (B.S.G.D.)',
        'Bachelor of Science in Information Systems (BSIS)',
        'Bachelor of Science in Information Technology (B.S.I.T.)',
      ],
    ),
    AcademicDepartment(
      name: 'School of Education',
      courses: [
        'Bachelor of Early Childhood Education (BECEd)',
        'Bachelor of Elementary Education (B.E.Ed.)',
        'Bachelor of Physical Education (BPEd)',
        'Bachelor of Secondary Education - Science (BSEd-Science)',
        'Bachelor of Secondary Education Major in English (BSEd-English)',
        'Bachelor of Secondary Education Major in Mathematics (BSEd-Math)',
        'Bachelor of Secondary Education-Filipino (BSEd-Filipino)',
        'Bachelor of Special Needs Education-Generalist '
            '(BSNEd-Generalist)',
        'Diploma in Professional Education (D.P.E.)',
      ],
    ),
    AcademicDepartment(
      name: 'School of Engineering & Architecture',
      courses: [
        'Bachelor of Science in Architecture (B.S. Archi)',
        'Bachelor of Science in Civil Engineering (B.S.C.E.)',
        'Bachelor of Science in Computer Engineering (B.S.Cp.E.)',
        'Bachelor of Science in Electrical Engineering (B.S.E.E.)',
        'Bachelor of Science in Electronics Engineering (B.S.E.C.E.)',
        'Bachelor of Science in Industrial Engineering (B.S.I.E.)',
        'Bachelor of Science in Mechanical Engineering (B.S.M.E.)',
        'Diploma in Civil Engineering Technology (D.C.E.T.)',
        'Diploma in Electrical Engineering Technology (D.E.E.T.)',
        'Diploma in Electronics Engineering Technology (D.E.C.E.T.)',
        'Diploma in Mechanical Engineering Technology (D.M.E.T.)',
      ],
    ),
  ];
}
