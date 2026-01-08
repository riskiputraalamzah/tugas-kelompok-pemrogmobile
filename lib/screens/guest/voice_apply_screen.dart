import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../config/theme.dart';
import '../../models/job.dart';
import 'voice_confirmation_screen.dart';

/// Data class for each voice input question
class VoiceQuestion {
  final String key;
  final String question;
  final String hint;
  final IconData icon;
  final bool isRequired;

  const VoiceQuestion({
    required this.key,
    required this.question,
    required this.hint,
    required this.icon,
    this.isRequired = true,
  });
}

class VoiceApplyScreen extends StatefulWidget {
  final Job job;

  const VoiceApplyScreen({super.key, required this.job});

  @override
  State<VoiceApplyScreen> createState() => _VoiceApplyScreenState();
}

class _VoiceApplyScreenState extends State<VoiceApplyScreen>
    with TickerProviderStateMixin {
  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _currentAnswer = '';

  // Animation controllers
  late AnimationController _micAnimController;
  late AnimationController _questionAnimController;
  late Animation<double> _micAnimation;
  late Animation<double> _questionFadeAnimation;
  late Animation<Offset> _questionSlideAnimation;

  // Question flow state
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {};
  int _listeningForQuestionIndex = -1; // Track which question we're listening for

  // Define questions matching form fields
  final List<VoiceQuestion> _questions = const [
    VoiceQuestion(
      key: 'fullName',
      question: 'Siapa nama lengkap Anda?',
      hint: 'Contoh: "Nama saya Budi Santoso"',
      icon: Icons.person,
    ),
    VoiceQuestion(
      key: 'email',
      question: 'Apa alamat email Anda?',
      hint: 'Contoh: "Email saya budi@gmail.com"',
      icon: Icons.email,
    ),
    VoiceQuestion(
      key: 'phone',
      question: 'Berapa nomor telepon Anda?',
      hint: 'Contoh: "Nomor saya 0812 3456 7890"',
      icon: Icons.phone,
    ),
    VoiceQuestion(
      key: 'education',
      question: 'Ceritakan riwayat pendidikan Anda',
      hint: 'Contoh: "Saya lulusan S1 Teknik Informatika dari Universitas..."',
      icon: Icons.school,
    ),
    VoiceQuestion(
      key: 'experience',
      question: 'Jelaskan pengalaman kerja Anda',
      hint: 'Contoh: "Saya pernah bekerja sebagai..." atau "Fresh graduate"',
      icon: Icons.work,
      isRequired: false,
    ),
    VoiceQuestion(
      key: 'skills',
      question: 'Sebutkan keahlian yang Anda miliki',
      hint: 'Contoh: "Keahlian saya meliputi Flutter, Python, dan..."',
      icon: Icons.psychology,
    ),
    VoiceQuestion(
      key: 'coverLetter',
      question: 'Mengapa Anda tertarik dengan posisi ini?',
      hint: 'Ceritakan motivasi dan alasan Anda melamar...',
      icon: Icons.edit_document,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initAnimations();
  }

  void _initSpeech() {
    _speech = stt.SpeechToText();
    _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        _micAnimController.stop();
      },
    ).then((available) {
      setState(() {
        _speechAvailable = available;
      });
    });
  }

  void _initAnimations() {
    // Microphone pulse animation
    _micAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _micAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _micAnimController, curve: Curves.easeInOut),
    );

    // Question transition animation
    _questionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _questionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionAnimController, curve: Curves.easeOut),
    );
    _questionSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _questionAnimController, curve: Curves.easeOut),
    );

    // Start question animation
    _questionAnimController.forward();
  }

  @override
  void dispose() {
    _micAnimController.dispose();
    _questionAnimController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      setState(() => _isListening = false);
      _micAnimController.stop();
      _micAnimController.reset();
    }
  }

  VoiceQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  bool get _isLastQuestion => _currentQuestionIndex >= _questions.length - 1;

  void _startListening() async {
    if (!_speechAvailable) {
      _showErrorSnackBar('Speech recognition tidak tersedia di perangkat ini');
      return;
    }

    if (_isListening) {
      _stopListening();
      return;
    }

    setState(() {
      _isListening = true;
      _currentAnswer = '';
    });

    _micAnimController.repeat(reverse: true);

    // Track which question we're listening for
    _listeningForQuestionIndex = _currentQuestionIndex;

    await _speech.listen(
      onResult: (result) {
        // Only update if still listening for the same question
        if (_listeningForQuestionIndex == _currentQuestionIndex) {
          setState(() {
            _currentAnswer = result.recognizedWords;
          });
        }
      },
      localeId: 'id_ID',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    _listeningForQuestionIndex = -1; // Reset listening tracker
    setState(() => _isListening = false);
    _micAnimController.stop();
    _micAnimController.reset();
  }

  void _saveCurrentAnswer() {
    if (_currentAnswer.isNotEmpty) {
      _answers[_currentQuestion.key] = _currentAnswer;
    }
  }

  void _retryCurrentQuestion() {
    setState(() {
      _currentAnswer = '';
    });
  }

  void _nextQuestion() {
    // Stop any ongoing speech recognition first
    if (_isListening) {
      _stopListening();
    }
    
    _saveCurrentAnswer();

    if (_isLastQuestion) {
      _navigateToConfirmation();
      return;
    }

    // Animate out, then in
    _questionAnimController.reverse().then((_) {
      setState(() {
        _currentQuestionIndex++;
        _currentAnswer = _answers[_currentQuestion.key] ?? '';
      });
      _questionAnimController.forward();
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex <= 0) return;

    // Stop any ongoing speech recognition first
    if (_isListening) {
      _stopListening();
    }

    _saveCurrentAnswer();

    _questionAnimController.reverse().then((_) {
      setState(() {
        _currentQuestionIndex--;
        _currentAnswer = _answers[_currentQuestion.key] ?? '';
      });
      _questionAnimController.forward();
    });
  }

  void _skipQuestion() {
    if (!_currentQuestion.isRequired) {
      _answers[_currentQuestion.key] = '';
      _nextQuestion();
    }
  }

  void _navigateToConfirmation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceConfirmationScreen(
          job: widget.job,
          answers: _answers,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Question area
            Expanded(
              child: _buildQuestionArea(),
            ),

            // Microphone and controls
            _buildControlsArea(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: 6,
        ),
      ),
    );
  }

  Widget _buildQuestionArea() {
    return FadeTransition(
      opacity: _questionFadeAnimation,
      child: SlideTransition(
        position: _questionSlideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Question icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentQuestion.icon,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),

              // Question text
              Text(
                _currentQuestion.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Hint text
              Text(
                _currentQuestion.hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Answer display area
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isListening
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.1),
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: Text(
                  _currentAnswer.isEmpty
                      ? (_isListening
                          ? 'Mendengarkan...'
                          : 'Tekan tombol mikrofon untuk mulai bicara')
                      : _currentAnswer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentAnswer.isEmpty
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white,
                    fontSize: 18,
                    fontStyle: _currentAnswer.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsArea() {
    return Column(
      children: [
        // Microphone button
        GestureDetector(
          onTap: _startListening,
          child: ScaleTransition(
            scale: _isListening
                ? _micAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Colors.red, Colors.redAccent]
                      : [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : AppTheme.primaryColor)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isListening ? 'Ketuk untuk berhenti' : 'Ketuk untuk bicara',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 24),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Back button
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),

              // Retry button
              if (_currentAnswer.isNotEmpty && !_isListening)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retryCurrentQuestion,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Ulangi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (_currentAnswer.isNotEmpty && !_isListening)
                const SizedBox(width: 12),

              // Skip button (for optional questions)
              if (!_currentQuestion.isRequired && _currentAnswer.isEmpty)
                Expanded(
                  child: TextButton(
                    onPressed: _skipQuestion,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),

              // Next / Finish button
              if (_currentAnswer.isNotEmpty && !_isListening)
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: Icon(
                      _isLastQuestion ? Icons.check : Icons.arrow_forward,
                      size: 18,
                    ),
                    label: Text(_isLastQuestion ? 'Selesai' : 'Lanjut'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
