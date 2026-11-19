# Rateel Academy - Bilingual Arabic-English Website for Quran and Arabic Learning

- Link: https://claude.ai/chat/bb025c49-a2eb-4996-adb4-3e470efcbb84
- Creata: 2025-05-17T11:14:15.449321Z
- Aggiornata: 2025-05-18T18:57:44.979677Z

## Yassin (2025-05-17T11:14)

Usong same colour of rateel build an Arabic English website as Academy for learning quran and Arabic with different paths and live teachers and courses certificate and other and rateel app will be showed also there and the price packages like various Academy zadul muslimito ecc

## Claude (2025-05-17T11:22)

# Rateel Academy Website Design

I'll create a responsive, bilingual (Arabic/English) landing page for Rateel Academy, maintaining the same emerald green and gold color scheme from the Rateel app. This will showcase Quran and Arabic learning programs, live teachers, certification, and pricing packages.

**Artifact: Rateel Academy Website** (`application/vnd.ant.react`, create)

```jsx
import React, { useState } from 'react';

// Main App Component
const RateelAcademy = () => {
  const [language, setLanguage] = useState('ar'); // 'ar' for Arabic, 'en' for English
  const [showMobileMenu, setShowMobileMenu] = useState(false);

  const toggleLanguage = () => {
    setLanguage(language === 'ar' ? 'en' : 'ar');
  };

  return (
    <div className={`min-h-screen bg-gradient-to-br from-primary-base to-primary-dark text-white ${language === 'ar' ? 'font-cairo rtl' : 'font-montserrat ltr'}`}>
      {/* Navbar */}
      <nav className="bg-primary-dark/80 backdrop-blur-md fixed w-full z-50 transition-all duration-300 shadow-md">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo and Brand Name */}
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="flex items-center">
                  <div className="w-10 h-10 flex items-center justify-center bg-accent-base/20 rounded-lg mr-2">
                    <i className="fas fa-book-quran text-accent-base text-xl"></i>
                  </div>
                  <span className="text-xl font-bold">
                    {language === 'ar' ? 'أكاديمية رَتِّل' : 'Rateel Academy'}
                  </span>
                </div>
              </div>
            </div>

            {/* Desktop Menu */}
            <div className="hidden md:block">
              <div className="flex items-center space-x-4 rtl:space-x-reverse">
                <NavItem href="#home" label={language === 'ar' ? 'الرئيسية' : 'Home'} current={true} />
                <NavItem href="#paths" label={language === 'ar' ? 'المسارات' : 'Paths'} />
                <NavItem href="#teachers" label={language === 'ar' ? 'المعلمون' : 'Teachers'} />
                <NavItem href="#courses" label={language === 'ar' ? 'الدورات' : 'Courses'} />
                <NavItem href="#pricing" label={language === 'ar' ? 'الأسعار' : 'Pricing'} />
                <NavItem href="#app" label={language === 'ar' ? 'التطبيق' : 'App'} />
                <NavItem href="#contact" label={language === 'ar' ? 'اتصل بنا' : 'Contact'} />
              </div>
            </div>

            {/* Right Side - Language Toggle and Auth Buttons */}
            <div className="flex items-center gap-2">
              <button 
                onClick={toggleLanguage} 
                className="p-2 rounded-full hover:bg-white/10 transition-colors"
              >
                <i className="fas fa-globe text-accent-base"></i>
                <span className="ml-1 text-sm hidden sm:inline">
                  {language === 'ar' ? 'English' : 'العربية'}
                </span>
              </button>
              
              <button className="bg-transparent text-accent-base border border-accent-base hover:bg-accent-base hover:text-primary-dark transition-colors px-3 py-1 rounded-full text-sm hidden sm:block">
                {language === 'ar' ? 'تسجيل الدخول' : 'Login'}
              </button>
              
              <button className="bg-accent-base text-primary-dark hover:bg-accent-bright transition-colors px-3 py-1 rounded-full text-sm hidden sm:block">
                {language === 'ar' ? 'ابدأ الآن' : 'Get Started'}
              </button>
              
              {/* Mobile Menu Button */}
              <button 
                onClick={() => setShowMobileMenu(!showMobileMenu)} 
                className="md:hidden p-2 rounded-full hover:bg-white/10 transition-colors"
              >
                <i className={`fas ${showMobileMenu ? 'fa-times' : 'fa-bars'} text-accent-base`}></i>
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        {showMobileMenu && (
          <div className="md:hidden bg-primary-dark/95 backdrop-blur-md">
            <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
              <MobileNavItem href="#home" label={language === 'ar' ? 'الرئيسية' : 'Home'} current={true} />
              <MobileNavItem href="#paths" label={language === 'ar' ? 'المسارات' : 'Paths'} />
              <MobileNavItem href="#teachers" label={language === 'ar' ? 'المعلمون' : 'Teachers'} />
              <MobileNavItem href="#courses" label={language === 'ar' ? 'الدورات' : 'Courses'} />
              <MobileNavItem href="#pricing" label={language === 'ar' ? 'الأسعار' : 'Pricing'} />
              <MobileNavItem href="#app" label={language === 'ar' ? 'التطبيق' : 'App'} />
              <MobileNavItem href="#contact" label={language === 'ar' ? 'اتصل بنا' : 'Contact'} />
            </div>
            <div className="px-4 py-3 flex gap-2">
              <button className="w-1/2 bg-transparent text-accent-base border border-accent-base hover:bg-accent-base hover:text-primary-dark transition-colors py-2 rounded-lg text-sm">
                {language === 'ar' ? 'تسجيل الدخول' : 'Login'}
              </button>
              <button className="w-1/2 bg-accent-base text-primary-dark hover:bg-accent-bright transition-colors py-2 rounded-lg text-sm">
                {language === 'ar' ? 'ابدأ الآن' : 'Get Started'}
              </button>
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main>
        {/* Hero Section */}
        <section id="home" className="pt-24 pb-16 relative overflow-hidden">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <div className="flex flex-wrap items-center">
              <div className="w-full lg:w-1/2 mb-12 lg:mb-0">
                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
                  {language === 'ar' 
                    ? 'تعلم القرآن والعربية بطريقة تفاعلية مبتكرة' 
                    : 'Learn Quran & Arabic with Interactive Innovation'
                  }
                </h1>
                <p className="text-lg mb-8 text-gray-300 max-w-lg">
                  {language === 'ar'
                    ? 'منصة متكاملة للتعلم عن بعد مع معلمين مؤهلين، دورات متنوعة، ومسارات تعليمية مخصصة لجميع المستويات والأعمار'
                    : 'A comprehensive platform for distance learning with qualified teachers, diverse courses, and educational paths customized for all levels and ages'
                  }
                </p>
                <div className="flex flex-wrap gap-4">
                  <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105 flex items-center">
                    {language === 'ar' ? 'ابدأ رحلتك التعليمية' : 'Start Your Learning Journey'}
                    <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
                  </button>
                  <button className="bg-transparent hover:bg-white/10 text-white border border-white/30 font-bold py-3 px-6 rounded-lg transition-all flex items-center">
                    {language === 'ar' ? 'تواصل معنا' : 'Contact Us'}
                    <i className="fas fa-headset ml-2"></i>
                  </button>
                </div>
                
                {/* Trust Indicators */}
                <div className="mt-12 flex flex-wrap gap-8">
                  <div className="flex items-center">
                    <div className="mr-3 bg-accent-base/20 p-2 rounded-full">
                      <i className="fas fa-users text-accent-base"></i>
                    </div>
                    <div>
                      <div className="text-2xl font-bold">15,000+</div>
                      <div className="text-sm text-gray-300">{language === 'ar' ? 'طالب' : 'Students'}</div>
                    </div>
                  </div>
                  
                  <div className="flex items-center">
                    <div className="mr-3 bg-accent-base/20 p-2 rounded-full">
                      <i className="fas fa-chalkboard-teacher text-accent-base"></i>
                    </div>
                    <div>
                      <div className="text-2xl font-bold">50+</div>
                      <div className="text-sm text-gray-300">{language === 'ar' ? 'معلم مؤهل' : 'Qualified Teachers'}</div>
                    </div>
                  </div>
                  
                  <div className="flex items-center">
                    <div className="mr-3 bg-accent-base/20 p-2 rounded-full">
                      <i className="fas fa-certificate text-accent-base"></i>
                    </div>
                    <div>
                      <div className="text-2xl font-bold">20+</div>
                      <div className="text-sm text-gray-300">{language === 'ar' ? 'دورة معتمدة' : 'Certified Courses'}</div>
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="w-full lg:w-1/2 relative">
                <div className="relative">
                  {/* Main Hero Image */}
                  <div className="bg-accent-base/10 p-3 rounded-2xl relative z-10 transform hover:scale-[1.02] transition-transform">
                    <img 
                      src="/api/placeholder/600/400" 
                      alt="Students learning Quran online" 
                      className="rounded-xl w-full h-auto"
                    />
                    {/* Decorative border */}
                    <div className="absolute -inset-1 border border-accent-base/30 rounded-2xl -z-10"></div>
                  </div>
                  
                  {/* Floating Elements */}
                  <div className="absolute -top-8 -left-8 bg-accent-base/80 p-3 rounded-lg shadow-lg transform -rotate-6 z-20">
                    <div className="flex items-center">
                      <div className="text-4xl text-primary-dark mr-3">
                        <i className="fas fa-quran"></i>
                      </div>
                      <div className="text-primary-dark">
                        <div className="font-bold">{language === 'ar' ? 'تعلم التجويد' : 'Learn Tajweed'}</div>
                        <div className="text-xs">{language === 'ar' ? 'بطريقة سهلة وميسرة' : 'Easy & Simplified'}</div>
                      </div>
                    </div>
                  </div>
                  
                  <div className="absolute -bottom-8 -right-8 bg-white p-3 rounded-lg shadow-lg transform rotate-3 z-20">
                    <div className="flex items-center">
                      <div className="text-4xl text-primary-dark mr-3">
                        <i className="fas fa-language"></i>
                      </div>
                      <div className="text-primary-dark">
                        <div className="font-bold">{language === 'ar' ? 'العربية للناطقين بغيرها' : 'Arabic for Non-Natives'}</div>
                        <div className="text-xs">{language === 'ar' ? 'منهج متكامل وشامل' : 'Comprehensive Curriculum'}</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Learning Paths Section */}
        <section id="paths" className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'مساراتنا التعليمية' : 'Our Learning Paths'} 
              subtitle={language === 'ar' 
                ? 'اختر المسار المناسب لاحتياجاتك وأهدافك' 
                : 'Choose the path that suits your needs and goals'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              {/* Quran Memorization Path */}
              <PathCard 
                icon="fa-quran"
                title={language === 'ar' ? 'حفظ القرآن الكريم' : 'Quran Memorization'}
                description={language === 'ar'
                  ? 'برنامج شامل لحفظ القرآن الكريم بإتقان، مع متابعة مستمرة وتقييم دوري للأداء'
                  : 'A comprehensive program for mastering Quran memorization, with continuous follow-up and periodic performance evaluation'
                }
                features={language === 'ar' 
                  ? ['حصص فردية مباشرة', 'خطة حفظ مخصصة', 'مراجعة مستمرة', 'شهادة إتمام'] 
                  : ['Live individual sessions', 'Customized memorization plan', 'Continuous revision', 'Completion certificate']
                }
                level={language === 'ar' ? 'جميع المستويات' : 'All Levels'}
                bgClass="bg-gradient-to-br from-accent-base/20 to-accent-dark/30"
              />
              
              {/* Tajweed Path */}
              <PathCard 
                icon="fa-microphone"
                title={language === 'ar' ? 'إتقان التجويد' : 'Tajweed Mastery'}
                description={language === 'ar'
                  ? 'تعلم أحكام التجويد بطريقة علمية مبسطة مع تطبيقات عملية ومتابعة من مشايخ متخصصين'
                  : 'Learn Tajweed rules through a simplified scientific method with practical applications and follow-up from specialized scholars'
                }
                features={language === 'ar' 
                  ? ['دروس نظرية وتطبيقية', 'تصحيح النطق', 'استخدام تطبيق رتل', 'تمارين متنوعة'] 
                  : ['Theoretical & practical lessons', 'Pronunciation correction', 'Using Rateel app', 'Various exercises']
                }
                level={language === 'ar' ? 'مبتدئ - متوسط - متقدم' : 'Beginner - Intermediate - Advanced'}
                bgClass="bg-gradient-to-br from-special-emerald/20 to-special-emerald/30"
              />
              
              {/* Arabic Language Path */}
              <PathCard 
                icon="fa-language"
                title={language === 'ar' ? 'اللغة العربية' : 'Arabic Language'}
                description={language === 'ar'
                  ? 'تعلم اللغة العربية للناطقين بغيرها، بمنهج متدرج يشمل المحادثة والقراءة والكتابة والقواعد'
                  : 'Learn Arabic for non-native speakers, with a progressive curriculum including conversation, reading, writing, and grammar'
                }
                features={language === 'ar' 
                  ? ['مستويات متعددة', 'تدريبات محادثة', 'تمارين كتابة', 'اختبارات دورية'] 
                  : ['Multiple levels', 'Conversation practice', 'Writing exercises', 'Periodic tests']
                }
                level={language === 'ar' ? 'من المبتدئ للمتقدم' : 'From Beginner to Advanced'}
                bgClass="bg-gradient-to-br from-secondary-blue/20 to-secondary-blue/30"
              />
              
              {/* Quranic Studies Path */}
              <PathCard 
                icon="fa-book"
                title={language === 'ar' ? 'الدراسات القرآنية' : 'Quranic Studies'}
                description={language === 'ar'
                  ? 'فهم معاني القرآن الكريم وعلومه من خلال دراسة التفسير وأسباب النزول وغيرها من العلوم'
                  : 'Understand the meanings of the Quran and its sciences through the study of Tafsir, reasons for revelation, and other sciences'
                }
                features={language === 'ar' 
                  ? ['دراسة التفسير', 'أسباب النزول', 'قواعد اللغة', 'مناقشات جماعية'] 
                  : ['Tafsir studies', 'Reasons for revelation', 'Language rules', 'Group discussions']
                }
                level={language === 'ar' ? 'متوسط - متقدم' : 'Intermediate - Advanced'}
                bgClass="bg-gradient-to-br from-secondary-purple/20 to-secondary-purple/30"
              />
              
              {/* Islamic Studies Path */}
              <PathCard 
                icon="fa-mosque"
                title={language === 'ar' ? 'الدراسات الإسلامية' : 'Islamic Studies'}
                description={language === 'ar'
                  ? 'دراسة العلوم الإسلامية المختلفة من عقيدة وفقه وسيرة وأخلاق وتاريخ إسلامي'
                  : 'Study various Islamic sciences including Aqeedah, Fiqh, Seerah, Ethics, and Islamic history'
                }
                features={language === 'ar' 
                  ? ['العقيدة الصحيحة', 'الفقه الإسلامي', 'السيرة النبوية', 'الأخلاق الإسلامية'] 
                  : ['Correct Aqeedah', 'Islamic Fiqh', 'Prophetic Seerah', 'Islamic Ethics']
                }
                level={language === 'ar' ? 'جميع المستويات' : 'All Levels'}
                bgClass="bg-gradient-to-br from-secondary-brown/20 to-secondary-brown/30"
              />
              
              {/* Children's Quran Path */}
              <PathCard 
                icon="fa-child"
                title={language === 'ar' ? 'تعليم الأطفال' : 'Children\'s Quran Learning'}
                description={language === 'ar'
                  ? 'برنامج خاص للأطفال يجمع بين التعلم والمتعة لتأسيس جيل متمكن من كتاب الله'
                  : 'A special program for children that combines learning with fun to establish a generation proficient in the Book of Allah'
                }
                features={language === 'ar' 
                  ? ['أنشطة تفاعلية', 'تقنيات مبتكرة', 'مكافآت تحفيزية', 'بيئة مرحة'] 
                  : ['Interactive activities', 'Innovative techniques', 'Motivational rewards', 'Fun environment']
                }
                level={language === 'ar' ? 'للأطفال من 5-15 سنة' : 'For children 5-15 years'}
                bgClass="bg-gradient-to-br from-special-ruby/20 to-special-ruby/30"
              />
            </div>
          </div>
        </section>

        {/* Teachers Section */}
        <section id="teachers" className="py-16 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <SectionHeader 
              title={language === 'ar' ? 'نخبة من المعلمين المتميزين' : 'Our Distinguished Teachers'} 
              subtitle={language === 'ar' 
                ? 'معلمون مؤهلون ذوو خبرة واسعة في التدريس والإجازات العلمية' 
                : 'Qualified teachers with extensive experience in teaching and academic licenses'
              } 
            />
            
            <div className="mt-12">
              {/* Teachers Slider */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <TeacherCard 
                  name={language === 'ar' ? 'الشيخ أحمد محمد' : 'Sheikh Ahmad Mohammad'}
                  title={language === 'ar' ? 'أستاذ القراءات وعلوم القرآن' : 'Professor of Quranic Readings'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '20+ سنة خبرة' : '20+ years experience'}
                  specialty={language === 'ar' ? 'حفظ القرآن والقراءات العشر' : 'Quran Memorization & 10 Readings'}
                  rating={4.9}
                />
                
                <TeacherCard 
                  name={language === 'ar' ? 'د. فاطمة العبدالله' : 'Dr. Fatima Al-Abdullah'}
                  title={language === 'ar' ? 'دكتوراه في اللغة العربية' : 'PhD in Arabic Language'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '15+ سنة خبرة' : '15+ years experience'}
                  specialty={language === 'ar' ? 'تعليم العربية للناطقين بغيرها' : 'Arabic for Non-native Speakers'}
                  rating={4.8}
                />
                
                <TeacherCard 
                  name={language === 'ar' ? 'الشيخ عبدالرحمن سعيد' : 'Sheikh Abdulrahman Saeed'}
                  title={language === 'ar' ? 'ماجستير في التفسير وعلوم القرآن' : 'Masters in Tafsir & Quranic Sciences'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '12+ سنة خبرة' : '12+ years experience'}
                  specialty={language === 'ar' ? 'التجويد والتلاوة' : 'Tajweed & Recitation'}
                  rating={4.9}
                />
                
                <TeacherCard 
                  name={language === 'ar' ? 'أ. نورة الفهد' : 'Ms. Noura Al-Fahd'}
                  title={language === 'ar' ? 'متخصصة في تعليم الأطفال' : 'Specialized in Children\'s Education'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '10+ سنة خبرة' : '10+ years experience'}
                  specialty={language === 'ar' ? 'تحفيظ القرآن للأطفال' : 'Quran Memorization for Children'}
                  rating={4.7}
                />
              </div>
              
              <div className="text-center mt-10">
                <button className="bg-transparent hover:bg-white/10 text-accent-base border border-accent-base hover:border-accent-bright font-bold py-2 px-6 rounded-lg transition-all transform hover:scale-105">
                  {language === 'ar' ? 'عرض جميع المعلمين' : 'View All Teachers'}
                  <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* Featured Courses Section */}
        <section id="courses" className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'الدورات المميزة' : 'Featured Courses'} 
              subtitle={language === 'ar' 
                ? 'دورات عالية الجودة مصممة لتلبية احتياجات الطلاب المختلفة' 
                : 'High-quality courses designed to meet the diverse needs of students'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              <CourseCard 
                title={language === 'ar' ? 'أساسيات التجويد للمبتدئين' : 'Tajweed Basics for Beginners'}
                instructor={language === 'ar' ? 'الشيخ عبدالرحمن سعيد' : 'Sheikh Abdulrahman Saeed'}
                image="/api/placeholder/400/250"
                level={language === 'ar' ? 'مبتدئ' : 'Beginner'}
                duration={language === 'ar' ? '12 أسبوع' : '12 weeks'}
                rating={4.8}
                students={342}
                price="99"
                discount="79"
                language={language}
              />
              
              <CourseCard 
                title={language === 'ar' ? 'العربية المعاصرة - المستوى الأول' : 'Modern Arabic - Level 1'}
                instructor={language === 'ar' ? 'د. فاطمة العبدالله' : 'Dr. Fatima Al-Abdullah'}
                image="/api/placeholder/400/250"
                level={language === 'ar' ? 'مبتدئ' : 'Beginner'}
                duration={language === 'ar' ? '16 أسبوع' : '16 weeks'}
                rating={4.9}
                students={520}
                price="129"
                discount="99"
                language={language}
              />
              
              <CourseCard 
                title={language === 'ar' ? 'حفظ جزء عم بالإتقان' : 'Memorize Juz\' Amma with Perfection'}
                instructor={language === 'ar' ? 'الشيخ أحمد محمد' : 'Sheikh Ahmad Mohammad'}
                image="/api/placeholder/400/250"
                level={language === 'ar' ? 'جميع المستويات' : 'All Levels'}
                duration={language === 'ar' ? '10 أسابيع' : '10 weeks'}
                rating={4.9}
                students={631}
                price="89"
                discount="69"
                language={language}
              />
            </div>
            
            <div className="text-center mt-10">
              <button className="bg-transparent hover:bg-white/10 text-accent-base border border-accent-base hover:border-accent-bright font-bold py-2 px-6 rounded-lg transition-all transform hover:scale-105">
                {language === 'ar' ? 'استكشف جميع الدورات' : 'Explore All Courses'}
                <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
              </button>
            </div>
          </div>
        </section>

        {/* Learning Features Section */}
        <section className="py-16 bg-gradient-to-br from-primary-dark to-primary-dark/80 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <SectionHeader 
              title={language === 'ar' ? 'مميزات التعلم معنا' : 'Our Learning Features'} 
              subtitle={language === 'ar' 
                ? 'نوفر تجربة تعليمية فريدة تجمع بين الأصالة والتقنية الحديثة' 
                : 'We provide a unique learning experience that combines authenticity and modern technology'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              <FeatureCard 
                icon="fa-video"
                title={language === 'ar' ? 'دروس مباشرة تفاعلية' : 'Interactive Live Lessons'}
                description={language === 'ar'
                  ? 'جلسات تعليمية مباشرة مع المعلم مع إمكانية التفاعل والمشاركة والأسئلة'
                  : 'Live educational sessions with the teacher with the ability to interact, participate, and ask questions'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-graduation-cap"
                title={language === 'ar' ? 'شهادات معتمدة' : 'Accredited Certificates'}
                description={language === 'ar'
                  ? 'شهادات إتمام معتمدة لجميع الدورات مع سلاسل إسناد للقراءات المختلفة'
                  : 'Accredited completion certificates for all courses with chains of narration for different readings'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-users"
                title={language === 'ar' ? 'حلقات تعلم جماعية' : 'Group Learning Circles'}
                description={language === 'ar'
                  ? 'حلقات تعليمية مصغرة تتيح التعلم في مجموعات مع زملاء ذوي اهتمامات متشابهة'
                  : 'Small educational circles that allow learning in groups with peers of similar interests'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-book-reader"
                title={language === 'ar' ? 'محتوى تعليمي متكامل' : 'Comprehensive Learning Content'}
                description={language === 'ar'
                  ? 'محتوى تعليمي شامل يتضمن الفيديوهات والكتب الإلكترونية والتمارين التفاعلية'
                  : 'Comprehensive educational content including videos, e-books, and interactive exercises'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-mobile-alt"
                title={language === 'ar' ? 'تطبيق رَتِّل للتعلم الذاتي' : 'Rateel App for Self-Learning'}
                description={language === 'ar'
                  ? 'تطبيق خاص للتعلم الذاتي ومتابعة التقدم وممارسة التجويد والتلاوة'
                  : 'A special app for self-learning, progress tracking, and practicing Tajweed and recitation'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-chart-line"
                title={language === 'ar' ? 'نظام متابعة التقدم' : 'Progress Tracking System'}
                description={language === 'ar'
                  ? 'نظام ذكي لمتابعة تقدم الطالب وتقييم الأداء وتوفير التغذية الراجعة المستمرة'
                  : 'Smart system for tracking student progress, evaluating performance, and providing continuous feedback'
                }
                language={language}
              />
            </div>
          </div>
        </section>

        {/* Pricing Section */}
        <section id="pricing" className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'خطط الاشتراك' : 'Subscription Plans'} 
              subtitle={language === 'ar' 
                ? 'اختر الخطة المناسبة لاحتياجاتك التعليمية وميزانيتك' 
                : 'Choose the plan that suits your educational needs and budget'
              } 
            />
            
            <div className="flex flex-wrap justify-center gap-8 mt-12">
              <PricingCard 
                title={language === 'ar' ? 'الباقة الأساسية' : 'Basic Package'}
                price="39"
                period={language === 'ar' ? 'شهرياً' : 'per month'}
                description={language === 'ar'
                  ? 'مناسبة للمبتدئين الراغبين في استكشاف المنصة'
                  : 'Suitable for beginners who want to explore the platform'
                }
                features={language === 'ar'
                  ? [
                      'حصتان أسبوعياً',
                      'معلم متخصص',
                      'منتدى للمناقشة',
                      'مكتبة المحتوى الأساسية',
                      'شهادة إتمام',
                    ]
                  : [
                      '2 Sessions per week',
                      'Specialized teacher',
                      'Discussion forum',
                      'Basic content library',
                      'Completion certificate',
                    ]
                }
                buttonText={language === 'ar' ? 'ابدأ الآن' : 'Get Started'}
                language={language}
                isPopular={false}
              />
              
              <PricingCard 
                title={language === 'ar' ? 'الباقة المتقدمة' : 'Advanced Package'}
                price="79"
                period={language === 'ar' ? 'شهرياً' : 'per month'}
                description={language === 'ar'
                  ? 'الخيار الأمثل لمعظم الطلاب بميزات متوازنة'
                  : 'The optimal choice for most students with balanced features'
                }
                features={language === 'ar'
                  ? [
                      '4 حصص أسبوعياً',
                      'معلم متخصص',
                      'جلسات فردية وجماعية',
                      'المكتبة الكاملة للمحتوى',
                      'تطبيق رتل المتكامل',
                      'شهادة معتمدة',
                      'دعم فني على مدار الساعة',
                    ]
                  : [
                      '4 Sessions per week',
                      'Specialized teacher',
                      'Individual & group sessions',
                      'Full content library',
                      'Integrated Rateel app',
                      'Accredited certificate',
                      '24/7 Technical support',
                    ]
                }
                buttonText={language === 'ar' ? 'اشترك الآن' : 'Subscribe Now'}
                language={language}
                isPopular={true}
              />
              
              <PricingCard 
                title={language === 'ar' ? 'الباقة الاحترافية' : 'Professional Package'}
                price="129"
                period={language === 'ar' ? 'شهرياً' : 'per month'}
                description={language === 'ar'
                  ? 'للطلاب الجادين الراغبين في تعلم مكثف ومخصص'
                  : 'For serious students who want intensive and personalized learning'
                }
                features={language === 'ar'
                  ? [
                      'حصص يومية مفتوحة',
                      'معلم خاص',
                      'خطة تعليمية مخصصة',
                      'جميع ميزات الباقة المتقدمة',
                      'جلسات تقييم منتظمة',
                      'إجازات معتمدة بالأسانيد',
                      'دعم بحثي وعلمي متكامل',
                    ]
                  : [
                      'Daily open sessions',
                      'Private teacher',
                      'Customized learning plan',
                      'All Advanced package features',
                      'Regular assessment sessions',
                      'Accredited Ijazat with Isnad',
                      'Comprehensive research support',
                    ]
                }
                buttonText={language === 'ar' ? 'اشترك الآن' : 'Subscribe Now'}
                language={language}
                isPopular={false}
              />
            </div>
            
            {/* Family Plan Banner */}
            <div className="mt-12 bg-accent-base/20 p-6 rounded-xl border border-accent-base/40">
              <div className="flex flex-wrap items-center justify-between">
                <div className="mb-4 md:mb-0">
                  <h3 className="text-xl font-bold text-accent-base mb-2">
                    {language === 'ar' ? 'باقة العائلة المميزة' : 'Special Family Package'}
                  </h3>
                  <p className="text-gray-300">
                    {language === 'ar'
                      ? 'اشترك لأفراد عائلتك واحصل على خصم 15% لكل فرد إضافي!'
                      : 'Subscribe for your family members and get a 15% discount for each additional member!'
                    }
                  </p>
                </div>
                <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-2 px-5 rounded-lg transition-all">
                  {language === 'ar' ? 'تفاصيل الباقة العائلية' : 'Family Package Details'}
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* App Showcase Section */}
        <section id="app" className="py-16 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <SectionHeader 
              title={language === 'ar' ? 'تطبيق رَتِّل للتعلم الذاتي' : 'Rateel App for Self-Learning'} 
              subtitle={language === 'ar' 
                ? 'التطبيق المساعد الأمثل لممارسة التجويد والتلاوة بتقنيات الذكاء الاصطناعي' 
                : 'The ideal assistant app for practicing Tajweed and recitation with AI technologies'
              } 
            />
            
            <div className="flex flex-wrap items-center mt-12 gap-12">
              <div className="w-full lg:w-5/12">
                <h3 className="text-3xl font-bold mb-6 text-accent-base">
                  {language === 'ar' ? 'تعلم التجويد بطريقة مبتكرة' : 'Learn Tajweed in an Innovative Way'}
                </h3>
                
                <div className="space-y-6">
                  <AppFeatureItem 
                    icon="fa-microphone"
                    title={language === 'ar' ? 'تصحيح التلاوة بالذكاء الاصطناعي' : 'AI Recitation Correction'}
                    description={language === 'ar'
                      ? 'تقنية متطورة للاستماع لتلاوتك وتحديد الأخطاء وتقديم الملاحظات لتحسين الأداء'
                      : 'Advanced technology to listen to your recitation, identify errors, and provide feedback to improve performance'
                    }
                    language={language}
                  />
                  
                  <AppFeatureItem 
                    icon="fa-book-open"
                    title={language === 'ar' ? 'دروس تفاعلية للتجويد' : 'Interactive Tajweed Lessons'}
                    description={language === 'ar'
                      ? 'تعلم قواعد التجويد خطوة بخطوة مع أمثلة توضيحية وتمارين تطبيقية'
                      : 'Learn Tajweed rules step by step with illustrative examples and practical exercises'
                    }
                    language={language}
                  />
                  
                  <AppFeatureItem 
                    icon="fa-trophy"
                    title={language === 'ar' ? 'نظام تحفيزي متكامل' : 'Integrated Motivational System'}
                    description={language === 'ar'
                      ? 'اكسب النقاط والإنجازات وارتق في المستويات كلما تقدمت في رحلة التعلم'
                      : 'Earn points and achievements and advance in levels as you progress in your learning journey'
                    }
                    language={language}
                  />
                  
                  <AppFeatureItem 
                    icon="fa-sync"
                    title={language === 'ar' ? 'مزامنة مع الدروس الحية' : 'Synchronization with Live Lessons'}
                    description={language === 'ar'
                      ? 'يتكامل التطبيق مع دروسك في الأكاديمية لتتبع تقدمك ومراجعة ما تم دراسته'
                      : 'The app integrates with your academy lessons to track your progress and review what you\'ve studied'
                    }
                    language={language}
                  />
                </div>
                
                <div className="mt-8 flex gap-4">
                  <button className="bg-black hover:bg-black/80 text-white font-bold py-2 px-4 rounded-lg transition-all flex items-center">
                    <i className="fab fa-apple text-2xl mr-2"></i>
                    <div className="text-left">
                      <div className="text-xs">{language === 'ar' ? 'متوفر على' : 'Available on'}</div>
                      <div>App Store</div>
                    </div>
                  </button>
                  
                  <button className="bg-black hover:bg-black/80 text-white font-bold py-2 px-4 rounded-lg transition-all flex items-center">
                    <i className="fab fa-google-play text-2xl mr-2"></i>
                    <div className="text-left">
                      <div className="text-xs">{language === 'ar' ? 'متوفر على' : 'Available on'}</div>
                      <div>Google Play</div>
                    </div>
                  </button>
                </div>
              </div>
              
              <div className="w-full lg:w-5/12 lg:ml-auto">
                <div className="relative">
                  {/* App Screenshots */}
                  <div className="relative z-10 transform rotate-3 hover:rotate-0 transition-transform duration-500">
                    <img 
                      src="/api/placeholder/500/300" 
                      alt="Rateel App Interface" 
                      className="rounded-xl shadow-2xl border-4 border-white/10"
                    />
                  </div>
                  
                  <div className="absolute -bottom-10 -left-10 z-0 transform -rotate-6 hover:rotate-0 transition-transform duration-500">
                    <img 
                      src="/api/placeholder/400/250" 
                      alt="Rateel App Feature" 
                      className="rounded-xl shadow-2xl border-4 border-white/10"
                    />
                  </div>
                  
                  {/* App Stats */}
                  <div className="absolute top-10 -right-5 bg-accent-base text-primary-dark p-4 rounded-lg transform rotate-6 shadow-lg z-20">
                    <div className="font-bold text-xl">100K+</div>
                    <div className="text-sm">{language === 'ar' ? 'تنزيل' : 'Downloads'}</div>
                  </div>
                  
                  <div className="absolute -bottom-5 right-20 bg-white text-primary-dark p-4 rounded-lg transform -rotate-3 shadow-lg z-20">
                    <div className="font-bold text-xl">4.8/5</div>
                    <div className="flex text-accent-base">
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star-half-alt"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Testimonials Section */}
        <section className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'آراء طلابنا' : 'Student Testimonials'} 
              subtitle={language === 'ar' 
                ? 'استمع إلى تجارب طلابنا وقصص نجاحهم مع أكاديمية رتل' 
                : 'Listen to our students\' experiences and success stories with Rateel Academy'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              <TestimonialCard 
                name={language === 'ar' ? 'محمد العتيبي' : 'Mohammed Al-Otaibi'}
                location={language === 'ar' ? 'الرياض، السعودية' : 'Riyadh, Saudi Arabia'}
                image="/api/placeholder/80/80"
                testimonial={language === 'ar'
                  ? 'بفضل أكاديمية رتل، تمكنت من حفظ 15 جزءاً من القرآن الكريم خلال عام واحد مع إتقان التجويد. المعلمون متميزون والمنهجية رائعة!'
                  : 'Thanks to Rateel Academy, I was able to memorize 15 parts of the Quran in one year with mastery of Tajweed. The teachers are excellent and the methodology is wonderful!'
                }
                language={language}
                course={language === 'ar' ? 'برنامج حفظ القرآن' : 'Quran Memorization Program'}
              />
              
              <TestimonialCard 
                name={language === 'ar' ? 'سارة الزهراني' : 'Sarah Al-Zahrani'}
                location={language === 'ar' ? 'دبي، الإمارات' : 'Dubai, UAE'}
                image="/api/placeholder/80/80"
                testimonial={language === 'ar'
                  ? 'كنت أبحث عن معلمة متخصصة لمساعدتي في تحسين تلاوتي، وفي رتل وجدت أفضل منصة. التعلم عن بعد مرن ومناسب لجدولي المزدحم.'
                  : 'I was looking for a specialized teacher to help me improve my recitation, and in Rateel I found the best platform. Distance learning is flexible and suitable for my busy schedule.'
                }
                language={language}
                course={language === 'ar' ? 'إتقان التجويد' : 'Tajweed Mastery'}
              />
              
              <TestimonialCard 
                name={language === 'ar' ? 'أحمد البلوشي' : 'Ahmed Al-Balushi'}
                location={language === 'ar' ? 'مسقط، عمان' : 'Muscat, Oman'}
                image="/api/placeholder/80/80"
                testimonial={language === 'ar'
                  ? 'كمبتدئ في تعلم اللغة العربية، كنت متردداً في البداية، لكن المنهج التدريجي والمعلمين الصبورين ساعدوني كثيراً. الآن أستطيع التحدث وقراءة القرآن بشكل أفضل.'
                  : 'As a beginner in learning Arabic, I was hesitant at first, but the gradual curriculum and patient teachers helped me a lot. Now I can speak and read the Quran better.'
                }
                language={language}
                course={language === 'ar' ? 'اللغة العربية للمبتدئين' : 'Arabic for Beginners'}
              />
            </div>
            
            {/* Video Testimonial */}
            <div className="mt-12 bg-primary-dark/60 p-6 rounded-xl">
              <div className="flex flex-wrap items-center gap-8">
                <div className="w-full lg:w-1/3">
                  <h3 className="text-2xl font-bold mb-4 text-accent-base">
                    {language === 'ar' ? 'قصص نجاح مع رتل' : 'Success Stories with Rateel'}
                  </h3>
                  <p className="text-gray-300 mb-6">
                    {language === 'ar'
                      ? 'استمع إلى قصص حقيقية من طلابنا حول كيف ساعدتهم أكاديمية رتل في تحقيق أهدافهم في تعلم القرآن واللغة العربية.'
                      : 'Listen to real stories from our students about how Rateel Academy helped them achieve their goals in learning the Quran and Arabic language.'
                    }
                  </p>
                  <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-2 px-5 rounded-lg transition-all">
                    {language === 'ar' ? 'مشاهدة المزيد من القصص' : 'Watch More Stories'}
                  </button>
                </div>
                
                <div className="w-full lg:w-3/5 lg:ml-auto">
                  <div className="relative overflow-hidden rounded-xl cursor-pointer group">
                    <img 
                      src="/api/placeholder/800/450" 
                      alt="Student Success Story" 
                      className="w-full h-auto rounded-xl transition-transform group-hover:scale-105"
                    />
                    <div className="absolute inset-0 flex items-center justify-center bg-black/40 group-hover:bg-black/50 transition-all">
                      <div className="bg-accent-base/90 text-primary-dark rounded-full w-16 h-16 flex items-center justify-center transform group-hover:scale-110 transition-transform">
                        <i className="fas fa-play text-xl"></i>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 bg-gradient-to-br from-accent-base/30 to-accent-dark/20 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <div className="text-center max-w-3xl mx-auto">
              <h2 className="text-3xl md:text-4xl font-bold mb-6 text-accent-base">
                {language === 'ar' 
                  ? 'ابدأ رحلتك التعليمية مع أكاديمية رَتِّل اليوم' 
                  : 'Start Your Learning Journey with Rateel Academy Today'
                }
              </h2>
              <p className="text-xl text-gray-300 mb-8">
                {language === 'ar'
                  ? 'انضم إلى الآلاف من الطلاب حول العالم واستفد من تجربة تعليمية فريدة مع نخبة من المعلمين المتخصصين'
                  : 'Join thousands of students around the world and benefit from a unique educational experience with elite specialized teachers'
                }
              </p>
              
              <div className="flex flex-wrap justify-center gap-4">
                <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-3 px-8 rounded-lg transition-all transform hover:scale-105">
                  {language === 'ar' ? 'سجل الآن' : 'Register Now'}
                </button>
                <button className="bg-transparent hover:bg-white/10 border border-accent-base text-accent-base font-bold py-3 px-8 rounded-lg transition-all transform hover:scale-105">
                  {language === 'ar' ? 'جلسة تجريبية مجانية' : 'Free Trial Session'}
                </button>
              </div>
              
              <div className="mt-10 flex justify-center gap-10 flex-wrap">
                <div className="flex items-center">
                  <i className="fas fa-check-circle text-accent-base text-xl mr-2"></i>
                  <span className="text-gray-300">
                    {language === 'ar' ? 'استرداد كامل لمدة 14 يوماً' : '14-day full refund'}
                  </span>
                </div>
                
                <div className="flex items-center">
                  <i className="fas fa-check-circle text-accent-base text-xl mr-2"></i>
                  <span className="text-gray-300">
                    {language === 'ar' ? 'دعم فني على مدار الساعة' : '24/7 technical support'}
                  </span>
                </div>
                
                <div className="flex items-center">
                  <i className="fas fa-check-circle text-accent-base text-xl mr-2"></i>
                  <span className="text-gray-300">
                    {language === 'ar' ? 'إلغاء الاشتراك في أي وقت' : 'Cancel subscription anytime'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Contact Section */}
        <section id="contact" className="py-16 bg-primary-dark">
          <div className="container mx-auto px-4">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              <div>
                <h2 className="text-3xl font-bold mb-6 text-accent-base">
                  {language === 'ar' ? 'تواصل معنا' : 'Contact Us'}
                </h2>
                <p className="text-gray-300 mb-8">
                  {language === 'ar'
                    ? 'نحن هنا للإجابة على استفساراتك ومساعدتك في اختيار البرنامج المناسب لك'
                    : 'We\'re here to answer your inquiries and help you choose the right program for you'
                  }
                </p>
                
                <div className="space-y-6">
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-envelope text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'البريد الإلكتروني' : 'Email'}
                      </h3>
                      <p className="text-gray-300">info@rateelacademy.com</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-phone-alt text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'الهاتف' : 'Phone'}
                      </h3>
                      <p className="text-gray-300">+966 12 345 6789</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-headset text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'الدعم الفني' : 'Technical Support'}
                      </h3>
                      <p className="text-gray-300">support@rateelacademy.com</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-clock text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'ساعات العمل' : 'Working Hours'}
                      </h3>
                      <p className="text-gray-300">
                        {language === 'ar' ? 'يومياً: 9 صباحاً - 10 مساءً (بتوقيت مكة)' : 'Daily: 9 AM - 10 PM (Makkah Time)'}
                      </p>
                    </div>
                  </div>
                </div>
                
                <div className="mt-8">
                  <h3 className="font-bold text-white mb-4">
                    {language === 'ar' ? 'تابعنا على' : 'Follow Us On'}
                  </h3>
                  <div className="flex space-x-4">
                    <a href="#" className="bg-accent-base/20 hover:bg-accent-base/40 p-3 rounded-full transition-colors">
                      <i className="fab fa-facebook-f text-accent-base"></i>
                    </a>
                    <a href="#" className="bg-accent-base/20 hover:bg-accent-base/40 p-3 rounded-full transition-colors">
                      <i className="fab fa-twitter text-accent-base"></i>
                    </a>
                    <a href="#" className="bg-accent-base/20 hover:bg-accent-base/40 p-3 rounded-full transition-colors">
                      <i className="fab fa-instagram text-accent-base"></i>
                    </a>
                    <a href="#" className="bg-accent-base/20 hover:bg-accent-base/40 p-3 rounded-full transition-colors">
                      <i className="fab fa-youtube text-accent-base"></i>
                    </a>
                    <a href="#" className="bg-accent-base/20 hover:bg-accent-base/40 p-3 rounded-full transition-colors">
                      <i className="fab fa-telegram text-accent-base"></i>
                    </a>
                  </div>
                </div>
              </div>
              
              <div>
                <form className="bg-primary-base/50 rounded-xl p-6 border border-white/10">
                  <h3 className="text-xl font-bold mb-6 text-accent-base">
                    {language === 'ar' ? 'أرسل رسالة' : 'Send a Message'}
                  </h3>
                  
                  <div className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-white mb-2">
                          {language === 'ar' ? 'الاسم' : 'Name'}
                        </label>
                        <input 
                          type="text" 
                          className="w-full bg-primary-dark border border-white/20 rounded-lg p-3 text-white focus:outline-none focus:border-accent-base"
                          placeholder={language === 'ar' ? 'أدخل اسمك' : 'Enter your name'}
                        />
                      </div>
                      
                      <div>
                        <label className="block text-white mb-2">
                          {language === 'ar' ? 'البريد الإلكتروني' : 'Email'}
                        </label>
                        <input 
                          type="email" 
                          className="w-full bg-primary-dark border border-white/20 rounded-lg p-3 text-white focus:outline-none focus:border-accent-base"
                          placeholder={language === 'ar' ? 'أدخل بريدك الإلكتروني' : 'Enter your email'}
                        />
                      </div>
                    </div>
                    
                    <div>
                      <label className="block text-white mb-2">
                        {language === 'ar' ? 'الموضوع' : 'Subject'}
                      </label>
                      <input 
                        type="text" 
                        className="w-full bg-primary-dark border border-white/20 rounded-lg p-3 text-white focus:outline-none focus:border-accent-base"
                        placeholder={language === 'ar' ? 'موضوع الرسالة' : 'Message subject'}
                      />
                    </div>
                    
                    <div>
                      <label className="block text-white mb-2">
                        {language === 'ar' ? 'الرسالة' : 'Message'}
                      </label>
                      <textarea 
                        className="w-full bg-primary-dark border border-white/20 rounded-lg p-3 text-white focus:outline-none focus:border-accent-base min-h-[150px]"
                        placeholder={language === 'ar' ? 'اكتب رسالتك هنا...' : 'Write your message here...'}
                      ></textarea>
                    </div>
                    
                    <button type="submit" className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-3 px-6 rounded-lg transition-all w-full">
                      {language === 'ar' ? 'إرسال الرسالة' : 'Send Message'}
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="bg-primary-dark/90 pt-16 pb-8">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center mb-4">
                <div className="w-10 h-10 flex items-center justify-center bg-accent-base/20 rounded-lg mr-2">
                  <i className="fas fa-book-quran text-accent-base text-xl"></i>
                </div>
                <span className="text-xl font-bold text-white">
                  {language === 'ar' ? 'أكاديمية رَتِّل' : 'Rateel Academy'}
                </span>
              </div>
              
              <p className="text-gray-400 mb-6">
                {language === 'ar'
                  ? 'منصة تعليمية متكاملة لتعليم القرآن الكريم واللغة العربية بمنهجية حديثة وتقنيات مبتكرة.'
                  : 'A comprehensive educational platform for teaching the Holy Quran and Arabic language with modern methodology and innovative technologies.'
                }
              </p>
              
              <div className="flex space-x-4">
                <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                  <i className="fab fa-facebook-f"></i>
                </a>
                <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                  <i className="fab fa-twitter"></i>
                </a>
                <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                  <i className="fab fa-instagram"></i>
                </a>
                <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                  <i className="fab fa-youtube"></i>
                </a>
              </div>
            </div>
            
            <div>
              <h4 className="text-white font-bold text-lg mb-4">
                {language === 'ar' ? 'روابط سريعة' : 'Quick Links'}
              </h4>
              
              <ul className="space-y-3">
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'البرامج التعليمية' : 'Educational Programs'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'المعلمون' : 'Teachers'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'جدول الحصص' : 'Class Schedule'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'الأسئلة الشائعة' : 'FAQs'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'حول الأكاديمية' : 'About the Academy'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'تطبيق رتل' : 'Rateel App'}
                  </a>
                </li>
              </ul>
            </div>
            
            <div>
              <h4 className="text-white font-bold text-lg mb-4">
                {language === 'ar' ? 'البرامج' : 'Programs'}
              </h4>
              
              <ul className="space-y-3">
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'حفظ القرآن الكريم' : 'Quran Memorization'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'إتقان التجويد' : 'Tajweed Mastery'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'تعليم اللغة العربية' : 'Arabic Language Teaching'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'الدراسات القرآنية' : 'Quranic Studies'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'برامج الأطفال' : 'Children\'s Programs'}
                  </a>
                </li>
                <li>
                  <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                    {language === 'ar' ? 'الإجازات والأسانيد' : 'Ijazat & Asanid'}
                  </a>
                </li>
              </ul>
            </div>
            
            <div>
              <h4 className="text-white font-bold text-lg mb-4">
                {language === 'ar' ? 'تحميل التطبيق' : 'Download the App'}
              </h4>
              
              <p className="text-gray-400 mb-4">
                {language === 'ar'
                  ? 'تطبيق رَتِّل متاح الآن للأجهزة المحمولة، قم بتنزيله اليوم!'
                  : 'Rateel app is now available for mobile devices, download it today!'
                }
              </p>
              
              <div className="space-y-4">
                <a href="#" className="bg-black hover:bg-black/80 text-white font-bold py-2 px-4 rounded-lg transition-all flex items-center w-36">
                  <i className="fab fa-apple text-2xl mr-2"></i>
                  <div className="text-left">
                    <div className="text-xs">{language === 'ar' ? 'متوفر على' : 'Available on'}</div>
                    <div>App Store</div>
                  </div>
                </a>
                
                <a href="#" className="bg-black hover:bg-black/80 text-white font-bold py-2 px-4 rounded-lg transition-all flex items-center w-36">
                  <i className="fab fa-google-play text-2xl mr-2"></i>
                  <div className="text-left">
                    <div className="text-xs">{language === 'ar' ? 'متوفر على' : 'Available on'}</div>
                    <div>Google Play</div>
                  </div>
                </a>
              </div>
            </div>
          </div>
          
          <div className="border-t border-white/10 mt-12 pt-8 flex flex-wrap justify-between">
            <div className="text-gray-400 mb-4 md:mb-0">
              &copy; {new Date().getFullYear()} {language === 'ar' ? 'أكاديمية رَتِّل. جميع الحقوق محفوظة' : 'Rateel Academy. All rights reserved'}
            </div>
            
            <div className="flex flex-wrap gap-4">
              <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                {language === 'ar' ? 'الشروط والأحكام' : 'Terms & Conditions'}
              </a>
              <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                {language === 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy'}
              </a>
              <a href="#" className="text-gray-400 hover:text-accent-base transition-colors">
                {language === 'ar' ? 'سياسة الاسترداد' : 'Refund Policy'}
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

// NavItem Component
const NavItem = ({ href, label, current = false }) => {
  return (
    <a
      href={href}
      className={`px-3 py-2 rounded-md text-sm font-medium ${
        current
          ? 'bg-accent-base/20 text-accent-base'
          : 'text-white hover:bg-white/10 hover:text-accent-base'
      } transition-colors`}
    >
      {label}
    </a>
  );
};

// Mobile NavItem Component
const MobileNavItem = ({ href, label, current = false }) => {
  return (
    <a
      href={href}
      className={`block px-3 py-2 rounded-md text-base font-medium ${
        current
          ? 'bg-accent-base/20 text-accent-base'
          : 'text-white hover:bg-white/10 hover:text-accent-base'
      } transition-colors`}
    >
      {label}
    </a>
  );
};

// Section Header Component
const SectionHeader = ({ title, subtitle }) => {
  return (
    <div className="text-center max-w-3xl mx-auto">
      <h2 className="text-3xl md:text-4xl font-bold mb-4 text-accent-base">{title}</h2>
      <p className="text-lg text-gray-300">{subtitle}</p>
      <div className="mt-4 flex justify-center">
        <div className="w-20 h-1 bg-accent-base rounded"></div>
      </div>
    </div>
  );
};

// Path Card Component
const PathCard = ({ icon, title, description, features, level, bgClass }) => {
  return (
    <div className={`rounded-xl p-6 ${bgClass} hover:scale-[1.02] transition-all duration-300`}>
      <div className="flex items-center mb-4">
        <div className="bg-accent-base/20 p-3 rounded-full">
          <i className={`fas ${icon} text-accent-base text-2xl`}></i>
        </div>
        <h3 className="text-xl font-bold ml-4 text-white">{title}</h3>
      </div>
      
      <p className="text-gray-300 mb-6">{description}</p>
      
      <ul className="space-y-2 mb-6">
        {features.map((feature, index) => (
          <li key={index} className="flex items-center">
            <i className="fas fa-check-circle text-accent-base mr-2"></i>
            <span className="text-gray-300">{feature}</span>
          </li>
        ))}
      </ul>
      
      <div className="flex justify-between items-center">
        <div className="bg-primary-dark/30 px-3 py-1 rounded-full">
          <span className="text-sm text-accent-base">{level}</span>
        </div>
        
        <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-2 px-4 rounded-lg transition-all">
          <i className="fas fa-arrow-right"></i>
        </button>
      </div>
    </div>
  );
};

// Teacher Card Component
const TeacherCard = ({ name, title, image, experience, specialty, rating }) => {
  return (
    <div className="bg-primary-dark/50 rounded-xl p-6 hover:scale-[1.02] transition-all duration-300 border border-white/5">
      <div className="flex flex-col items-center text-center">
        <div className="w-24 h-24 mb-4 rounded-full overflow-hidden border-2 border-accent-base/30">
          <img src={image} alt={name} className="w-full h-full object-cover" />
        </div>
        
        <h3 className="text-xl font-bold text-white mb-1">{name}</h3>
        <p className="text-accent-base mb-4">{title}</p>
        
        <div className="flex items-center mb-2">
          <div className="text-yellow-400 flex">
            <i className="fas fa-star"></i>
            <i className="fas fa-star"></i>
            <i className="fas fa-star"></i>
            <i className="fas fa-star"></i>
            <i className="fas fa-star-half-alt"></i>
          </div>
          <span className="text-gray-300 ml-2">{rating}</span>
        </div>
        
        <div className="flex flex-col gap-2 mb-4 w-full">
          <div className="flex items-center">
            <i className="fas fa-clock text-accent-base text-sm mr-2"></i>
            <span className="text-gray-300 text-sm">{experience}</span>
          </div>
          <div className="flex items-center">
            <i className="fas fa-graduation-cap text-accent-base text-sm mr-2"></i>
            <span className="text-gray-300 text-sm">{specialty}</span>
          </div>
        </div>
        
        <button className="bg-transparent hover:bg-accent-base/10 border border-accent-base text-accent-base hover:text-accent-bright font-bold py-2 px-4 rounded-lg transition-all w-full">
          عرض الملف الشخصي
        </button>
      </div>
    </div>
  );
};

// Course Card Component
const CourseCard = ({ title, instructor, image, level, duration, rating, students, price, discount, language }) => {
  return (
    <div className="bg-primary-dark/50 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-[1.02] border border-white/5">
      <div className="relative">
        <img src={image} alt={title} className="w-full h-48 object-cover" />
        <div className="absolute top-4 right-4 bg-accent-base text-primary-dark font-bold py-1 px-3 rounded-full">
          {level}
        </div>
      </div>
      
      <div className="p-6">
        <h3 className="text-xl font-bold text-white mb-2 line-clamp-2 h-14">{title}</h3>
        
        <div className="flex items-center mb-4">
          <img src="/api/placeholder/30/30" alt={instructor} className="w-6 h-6 rounded-full mr-2" />
          <span className="text-gray-300 text-sm">{instructor}</span>
        </div>
        
        <div className="flex justify-between mb-4">
          <div className="flex items-center">
            <i className="fas fa-star text-yellow-400 mr-1"></i>
            <span className="text-gray-300">{rating} ({students})</span>
          </div>
          
          <div className="flex items-center">
            <i className="fas fa-clock text-accent-base mr-1"></i>
            <span className="text-gray-300">{duration}</span>
          </div>
        </div>
        
        <div className="border-t border-white/10 pt-4 flex justify-between items-center">
          <div>
            <span className="text-accent-base font-bold text-xl">${discount}</span>
            <span className="text-gray-400 line-through ml-2">${price}</span>
          </div>
          
          <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-2 px-4 rounded-lg transition-all">
            {language === 'ar' ? 'اشترك الآن' : 'Enroll Now'}
          </button>
        </div>
      </div>
    </div>
  );
};

// Feature Card Component
const FeatureCard = ({ icon, title, description, language }) => {
  return (
    <div className="bg-primary-dark/60 rounded-xl p-6 border border-white/5 hover:border-accent-base/30 transition-all duration-300 hover:scale-[1.02]">
      <div className="bg-accent-base/20 w-14 h-14 rounded-full flex items-center justify-center mb-4">
        <i className={`fas ${icon} text-accent-base text-2xl`}></i>
      </div>
      
      <h3 className="text-xl font-bold text-white mb-3">{title}</h3>
      <p className="text-gray-300">{description}</p>
      
      <div className="mt-4">
        <a href="#" className="text-accent-base hover:text-accent-bright transition-colors inline-flex items-center">
          <span>{language === 'ar' ? 'اقرأ المزيد' : 'Read More'}</span>
          <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
        </a>
      </div>
    </div>
  );
};

// Pricing Card Component
const PricingCard = ({ title, price, period, description, features, buttonText, language, isPopular }) => {
  return (
    <div className={`
      bg-primary-dark/50 rounded-xl overflow-hidden w-full max-w-sm 
      ${isPopular ? 'border-2 border-accent-base relative transform scale-105' : 'border border-white/10'} 
      hover:scale-[1.02] transition-all duration-300
    `}>
      {isPopular && (
        <div className="absolute top-6 right-0 bg-accent-base text-primary-dark font-bold py-1 px-6 shadow-lg transform rotate-45 translate-x-7">
          {language === 'ar' ? 'الأكثر شعبية' : 'Most Popular'}
        </div>
      )}
      
      <div className={`p-8 pb-4 ${isPopular ? 'bg-accent-base/20' : ''}`}>
        <h3 className="text-2xl font-bold text-white mb-2">{title}</h3>
        <p className="text-gray-300 mb-4">{description}</p>
        
        <div className="mb-6">
          <span className="text-accent-base text-4xl font-bold">${price}</span>
          <span className="text-gray-300 ml-2">{period}</span>
        </div>
      </div>
      
      <div className="p-8 pt-4">
        <ul className="space-y-4 mb-8">
          {features.map((feature, index) => (
            <li key={index} className="flex items-center">
              <i className="fas fa-check-circle text-accent-base mr-3"></i>
              <span className="text-gray-300">{feature}</span>
            </li>
          ))}
        </ul>
        
        <button className={`
          w-full py-3 px-6 rounded-lg font-bold transition-all
          ${isPopular
            ? 'bg-accent-base hover:bg-accent-bright text-primary-dark'
            : 'bg-transparent hover:bg-white/10 text-accent-base border border-accent-base'
          }
        `}>
          {buttonText}
        </button>
      </div>
    </div>
  );
};

// App Feature Item Component
const AppFeatureItem = ({ icon, title, description, language }) => {
  return (
    <div className="flex">
      <div className="flex-shrink-0">
        <div className="bg-accent-base/20 w-12 h-12 rounded-full flex items-center justify-center">
          <i className={`fas ${icon} text-accent-base text-xl`}></i>
        </div>
      </div>
      
      <div className={`flex-grow ${language === 'ar' ? 'mr-4' : 'ml-4'}`}>
        <h3 className="text-xl font-bold text-white mb-2">{title}</h3>
        <p className="text-gray-300">{description}</p>
      </div>
    </div>
  );
};

// Testimonial Card Component
const TestimonialCard = ({ name, location, image, testimonial, language, course }) => {
  return (
    <div className="bg-primary-dark/50 rounded-xl p-6 border border-white/5 hover:border-accent-base/30 transition-all duration-300 hover:scale-[1.02]">
      <div className="mb-4 relative">
        <i className="fas fa-quote-right text-accent-base/20 text-6xl absolute -top-2 -right-2"></i>
        <p className="text-gray-300 relative z-10">{testimonial}</p>
      </div>
      
      <div className="flex items-center">
        <img src={image} alt={name} className="w-14 h-14 rounded-full mr-4 border-2 border-accent-base/30" />
        
        <div>
          <h4 className="font-bold text-white">{name}</h4>
          <p className="text-gray-400 text-sm">{location}</p>
          <div className="mt-1 flex items-center">
            <i className="fas fa-graduation-cap text-accent-base text-xs mr-1"></i>
            <span className="text-accent-base text-xs">{course}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RateelAcademy;

```

<details><summary>risultato tool</summary>

```
Automated System Error: The generated artifact uses unsupported HTML elements: form
```
</details>



Let me fix that and create a responsive bilingual (Arabic/English) landing page for Rateel Academy, maintaining the same emerald green and gold color scheme from the Rateel app.

**Artifact: artifact** (``, create)

```
import React, { useState } from 'react';

// Main App Component
const RateelAcademy = () => {
  const [language, setLanguage] = useState('ar'); // 'ar' for Arabic, 'en' for English
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [contactFormData, setContactFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  });

  const toggleLanguage = () => {
    setLanguage(language === 'ar' ? 'en' : 'ar');
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setContactFormData({
      ...contactFormData,
      [name]: value
    });
  };

  const handleContactSubmit = (e) => {
    e.preventDefault();
    // In a real app, we would send this data to a backend
    console.log('Contact form data:', contactFormData);
    // Reset form
    setContactFormData({
      name: '',
      email: '',
      subject: '',
      message: ''
    });
    // Show success message (in a real app)
    alert(language === 'ar' ? 'تم إرسال الرسالة بنجاح!' : 'Message sent successfully!');
  };

  return (
    <div className={`min-h-screen bg-gradient-to-br from-primary-base to-primary-dark text-white ${language === 'ar' ? 'font-cairo rtl' : 'font-montserrat ltr'}`}>
      {/* Navbar */}
      <nav className="bg-primary-dark/80 backdrop-blur-md fixed w-full z-50 transition-all duration-300 shadow-md">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo and Brand Name */}
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="flex items-center">
                  <div className="w-10 h-10 flex items-center justify-center bg-accent-base/20 rounded-lg mr-2">
                    <i className="fas fa-book-quran text-accent-base text-xl"></i>
                  </div>
                  <span className="text-xl font-bold">
                    {language === 'ar' ? 'أكاديمية رَتِّل' : 'Rateel Academy'}
                  </span>
                </div>
              </div>
            </div>

            {/* Desktop Menu */}
            <div className="hidden md:block">
              <div className="flex items-center space-x-4 rtl:space-x-reverse">
                <NavItem href="#home" label={language === 'ar' ? 'الرئيسية' : 'Home'} current={true} />
                <NavItem href="#paths" label={language === 'ar' ? 'المسارات' : 'Paths'} />
                <NavItem href="#teachers" label={language === 'ar' ? 'المعلمون' : 'Teachers'} />
                <NavItem href="#courses" label={language === 'ar' ? 'الدورات' : 'Courses'} />
                <NavItem href="#pricing" label={language === 'ar' ? 'الأسعار' : 'Pricing'} />
                <NavItem href="#app" label={language === 'ar' ? 'التطبيق' : 'App'} />
                <NavItem href="#contact" label={language === 'ar' ? 'اتصل بنا' : 'Contact'} />
              </div>
            </div>

            {/* Right Side - Language Toggle and Auth Buttons */}
            <div className="flex items-center gap-2">
              <button 
                onClick={toggleLanguage} 
                className="p-2 rounded-full hover:bg-white/10 transition-colors"
              >
                <i className="fas fa-globe text-accent-base"></i>
                <span className="ml-1 text-sm hidden sm:inline">
                  {language === 'ar' ? 'English' : 'العربية'}
                </span>
              </button>
              
              <button className="bg-transparent text-accent-base border border-accent-base hover:bg-accent-base hover:text-primary-dark transition-colors px-3 py-1 rounded-full text-sm hidden sm:block">
                {language === 'ar' ? 'تسجيل الدخول' : 'Login'}
              </button>
              
              <button className="bg-accent-base text-primary-dark hover:bg-accent-bright transition-colors px-3 py-1 rounded-full text-sm hidden sm:block">
                {language === 'ar' ? 'ابدأ الآن' : 'Get Started'}
              </button>
              
              {/* Mobile Menu Button */}
              <button 
                onClick={() => setShowMobileMenu(!showMobileMenu)} 
                className="md:hidden p-2 rounded-full hover:bg-white/10 transition-colors"
              >
                <i className={`fas ${showMobileMenu ? 'fa-times' : 'fa-bars'} text-accent-base`}></i>
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        {showMobileMenu && (
          <div className="md:hidden bg-primary-dark/95 backdrop-blur-md">
            <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
              <MobileNavItem href="#home" label={language === 'ar' ? 'الرئيسية' : 'Home'} current={true} />
              <MobileNavItem href="#paths" label={language === 'ar' ? 'المسارات' : 'Paths'} />
              <MobileNavItem href="#teachers" label={language === 'ar' ? 'المعلمون' : 'Teachers'} />
              <MobileNavItem href="#courses" label={language === 'ar' ? 'الدورات' : 'Courses'} />
              <MobileNavItem href="#pricing" label={language === 'ar' ? 'الأسعار' : 'Pricing'} />
              <MobileNavItem href="#app" label={language === 'ar' ? 'التطبيق' : 'App'} />
              <MobileNavItem href="#contact" label={language === 'ar' ? 'اتصل بنا' : 'Contact'} />
            </div>
            <div className="px-4 py-3 flex gap-2">
              <button className="w-1/2 bg-transparent text-accent-base border border-accent-base hover:bg-accent-base hover:text-primary-dark transition-colors py-2 rounded-lg text-sm">
                {language === 'ar' ? 'تسجيل الدخول' : 'Login'}
              </button>
              <button className="w-1/2 bg-accent-base text-primary-dark hover:bg-accent-bright transition-colors py-2 rounded-lg text-sm">
                {language === 'ar' ? 'ابدأ الآن' : 'Get Started'}
              </button>
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main>
        {/* Hero Section */}
        <section id="home" className="pt-24 pb-16 relative overflow-hidden">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <div className="flex flex-wrap items-center">
              <div className="w-full lg:w-1/2 mb-12 lg:mb-0">
                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
                  {language === 'ar' 
                    ? 'تعلم القرآن والعربية بطريقة تفاعلية مبتكرة' 
                    : 'Learn Quran & Arabic with Interactive Innovation'
                  }
                </h1>
                <p className="text-lg mb-8 text-gray-300 max-w-lg">
                  {language === 'ar'
                    ? 'منصة متكاملة للتعلم عن بعد مع معلمين مؤهلين، دورات متنوعة، ومسارات تعليمية مخصصة لجميع المستويات والأعمار'
                    : 'A comprehensive platform for distance learning with qualified teachers, diverse courses, and educational paths customized for all levels and ages'
                  }
                </p>
                <div className="flex flex-wrap gap-4">
                  <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-3 px-6 rounded-lg transition-all transform hover:scale-105 flex items-center">
                    {language === 'ar' ? 'ابدأ رحلتك التعليمية' : 'Start Your Learning Journey'}
                    <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
                  </button>
                  <button className="bg-transparent hover:bg-white/10 text-white border border-white/30 font-bold py-3 px-6 rounded-lg transition-all flex items-center">
                    {language === 'ar' ? 'تواصل معنا' : 'Contact Us'}
                    <i className="fas fa-headset ml-2"></i>
                  </button>
                </div>
                
                {/* Trust Indicators */}
                <div className="mt-12 flex flex-wrap gap-8">
                  <div className="flex items-center">
                    <div className="mr-3 bg-accent-base/20 p-2 rounded-full">
                      <i className="fas fa-users text-accent-base"></i>
                    </div>
                    <div>
                      <div className="text-2xl font-bold">15,000+</div>
                      <div className="text-sm text-gray-300">{language === 'ar' ? 'طالب' : 'Students'}</div>
                    </div>
                  </div>
                  
                  <div className="flex items-center">
                    <div className="mr-3 bg-accent-base/20 p-2 rounded-full">
                      <i className="fas fa-chalkboard-teacher text-accent-base"></i>
                    </div>
                    <div>
                      <div className="text-2xl font-bold">50+</div>
                      <div className="text-sm text-gray-300">{language === 'ar' ? 'معلم مؤهل' : 'Qualified Teachers'}</div>
                    </div>
                  </div>
                  
                  <div className="flex items-center">
                    <div className="mr-3 bg-accent-base/20 p-2 rounded-full">
                      <i className="fas fa-certificate text-accent-base"></i>
                    </div>
                    <div>
                      <div className="text-2xl font-bold">20+</div>
                      <div className="text-sm text-gray-300">{language === 'ar' ? 'دورة معتمدة' : 'Certified Courses'}</div>
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="w-full lg:w-1/2 relative">
                <div className="relative">
                  {/* Main Hero Image */}
                  <div className="bg-accent-base/10 p-3 rounded-2xl relative z-10 transform hover:scale-[1.02] transition-transform">
                    <img 
                      src="/api/placeholder/600/400" 
                      alt="Students learning Quran online" 
                      className="rounded-xl w-full h-auto"
                    />
                    {/* Decorative border */}
                    <div className="absolute -inset-1 border border-accent-base/30 rounded-2xl -z-10"></div>
                  </div>
                  
                  {/* Floating Elements */}
                  <div className="absolute -top-8 -left-8 bg-accent-base/80 p-3 rounded-lg shadow-lg transform -rotate-6 z-20">
                    <div className="flex items-center">
                      <div className="text-4xl text-primary-dark mr-3">
                        <i className="fas fa-quran"></i>
                      </div>
                      <div className="text-primary-dark">
                        <div className="font-bold">{language === 'ar' ? 'تعلم التجويد' : 'Learn Tajweed'}</div>
                        <div className="text-xs">{language === 'ar' ? 'بطريقة سهلة وميسرة' : 'Easy & Simplified'}</div>
                      </div>
                    </div>
                  </div>
                  
                  <div className="absolute -bottom-8 -right-8 bg-white p-3 rounded-lg shadow-lg transform rotate-3 z-20">
                    <div className="flex items-center">
                      <div className="text-4xl text-primary-dark mr-3">
                        <i className="fas fa-language"></i>
                      </div>
                      <div className="text-primary-dark">
                        <div className="font-bold">{language === 'ar' ? 'العربية للناطقين بغيرها' : 'Arabic for Non-Natives'}</div>
                        <div className="text-xs">{language === 'ar' ? 'منهج متكامل وشامل' : 'Comprehensive Curriculum'}</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Learning Paths Section */}
        <section id="paths" className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'مساراتنا التعليمية' : 'Our Learning Paths'} 
              subtitle={language === 'ar' 
                ? 'اختر المسار المناسب لاحتياجاتك وأهدافك' 
                : 'Choose the path that suits your needs and goals'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              {/* Quran Memorization Path */}
              <PathCard 
                icon="fa-quran"
                title={language === 'ar' ? 'حفظ القرآن الكريم' : 'Quran Memorization'}
                description={language === 'ar'
                  ? 'برنامج شامل لحفظ القرآن الكريم بإتقان، مع متابعة مستمرة وتقييم دوري للأداء'
                  : 'A comprehensive program for mastering Quran memorization, with continuous follow-up and periodic performance evaluation'
                }
                features={language === 'ar' 
                  ? ['حصص فردية مباشرة', 'خطة حفظ مخصصة', 'مراجعة مستمرة', 'شهادة إتمام'] 
                  : ['Live individual sessions', 'Customized memorization plan', 'Continuous revision', 'Completion certificate']
                }
                level={language === 'ar' ? 'جميع المستويات' : 'All Levels'}
                bgClass="bg-gradient-to-br from-accent-base/20 to-accent-dark/30"
              />
              
              {/* Tajweed Path */}
              <PathCard 
                icon="fa-microphone"
                title={language === 'ar' ? 'إتقان التجويد' : 'Tajweed Mastery'}
                description={language === 'ar'
                  ? 'تعلم أحكام التجويد بطريقة علمية مبسطة مع تطبيقات عملية ومتابعة من مشايخ متخصصين'
                  : 'Learn Tajweed rules through a simplified scientific method with practical applications and follow-up from specialized scholars'
                }
                features={language === 'ar' 
                  ? ['دروس نظرية وتطبيقية', 'تصحيح النطق', 'استخدام تطبيق رتل', 'تمارين متنوعة'] 
                  : ['Theoretical & practical lessons', 'Pronunciation correction', 'Using Rateel app', 'Various exercises']
                }
                level={language === 'ar' ? 'مبتدئ - متوسط - متقدم' : 'Beginner - Intermediate - Advanced'}
                bgClass="bg-gradient-to-br from-special-emerald/20 to-special-emerald/30"
              />
              
              {/* Arabic Language Path */}
              <PathCard 
                icon="fa-language"
                title={language === 'ar' ? 'اللغة العربية' : 'Arabic Language'}
                description={language === 'ar'
                  ? 'تعلم اللغة العربية للناطقين بغيرها، بمنهج متدرج يشمل المحادثة والقراءة والكتابة والقواعد'
                  : 'Learn Arabic for non-native speakers, with a progressive curriculum including conversation, reading, writing, and grammar'
                }
                features={language === 'ar' 
                  ? ['مستويات متعددة', 'تدريبات محادثة', 'تمارين كتابة', 'اختبارات دورية'] 
                  : ['Multiple levels', 'Conversation practice', 'Writing exercises', 'Periodic tests']
                }
                level={language === 'ar' ? 'من المبتدئ للمتقدم' : 'From Beginner to Advanced'}
                bgClass="bg-gradient-to-br from-secondary-blue/20 to-secondary-blue/30"
              />
              
              {/* Quranic Studies Path */}
              <PathCard 
                icon="fa-book"
                title={language === 'ar' ? 'الدراسات القرآنية' : 'Quranic Studies'}
                description={language === 'ar'
                  ? 'فهم معاني القرآن الكريم وعلومه من خلال دراسة التفسير وأسباب النزول وغيرها من العلوم'
                  : 'Understand the meanings of the Quran and its sciences through the study of Tafsir, reasons for revelation, and other sciences'
                }
                features={language === 'ar' 
                  ? ['دراسة التفسير', 'أسباب النزول', 'قواعد اللغة', 'مناقشات جماعية'] 
                  : ['Tafsir studies', 'Reasons for revelation', 'Language rules', 'Group discussions']
                }
                level={language === 'ar' ? 'متوسط - متقدم' : 'Intermediate - Advanced'}
                bgClass="bg-gradient-to-br from-secondary-purple/20 to-secondary-purple/30"
              />
              
              {/* Islamic Studies Path */}
              <PathCard 
                icon="fa-mosque"
                title={language === 'ar' ? 'الدراسات الإسلامية' : 'Islamic Studies'}
                description={language === 'ar'
                  ? 'دراسة العلوم الإسلامية المختلفة من عقيدة وفقه وسيرة وأخلاق وتاريخ إسلامي'
                  : 'Study various Islamic sciences including Aqeedah, Fiqh, Seerah, Ethics, and Islamic history'
                }
                features={language === 'ar' 
                  ? ['العقيدة الصحيحة', 'الفقه الإسلامي', 'السيرة النبوية', 'الأخلاق الإسلامية'] 
                  : ['Correct Aqeedah', 'Islamic Fiqh', 'Prophetic Seerah', 'Islamic Ethics']
                }
                level={language === 'ar' ? 'جميع المستويات' : 'All Levels'}
                bgClass="bg-gradient-to-br from-secondary-brown/20 to-secondary-brown/30"
              />
              
              {/* Children's Quran Path */}
              <PathCard 
                icon="fa-child"
                title={language === 'ar' ? 'تعليم الأطفال' : 'Children\'s Quran Learning'}
                description={language === 'ar'
                  ? 'برنامج خاص للأطفال يجمع بين التعلم والمتعة لتأسيس جيل متمكن من كتاب الله'
                  : 'A special program for children that combines learning with fun to establish a generation proficient in the Book of Allah'
                }
                features={language === 'ar' 
                  ? ['أنشطة تفاعلية', 'تقنيات مبتكرة', 'مكافآت تحفيزية', 'بيئة مرحة'] 
                  : ['Interactive activities', 'Innovative techniques', 'Motivational rewards', 'Fun environment']
                }
                level={language === 'ar' ? 'للأطفال من 5-15 سنة' : 'For children 5-15 years'}
                bgClass="bg-gradient-to-br from-special-ruby/20 to-special-ruby/30"
              />
            </div>
          </div>
        </section>

        {/* Teachers Section */}
        <section id="teachers" className="py-16 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <SectionHeader 
              title={language === 'ar' ? 'نخبة من المعلمين المتميزين' : 'Our Distinguished Teachers'} 
              subtitle={language === 'ar' 
                ? 'معلمون مؤهلون ذوو خبرة واسعة في التدريس والإجازات العلمية' 
                : 'Qualified teachers with extensive experience in teaching and academic licenses'
              } 
            />
            
            <div className="mt-12">
              {/* Teachers Slider */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <TeacherCard 
                  name={language === 'ar' ? 'الشيخ أحمد محمد' : 'Sheikh Ahmad Mohammad'}
                  title={language === 'ar' ? 'أستاذ القراءات وعلوم القرآن' : 'Professor of Quranic Readings'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '20+ سنة خبرة' : '20+ years experience'}
                  specialty={language === 'ar' ? 'حفظ القرآن والقراءات العشر' : 'Quran Memorization & 10 Readings'}
                  rating={4.9}
                />
                
                <TeacherCard 
                  name={language === 'ar' ? 'د. فاطمة العبدالله' : 'Dr. Fatima Al-Abdullah'}
                  title={language === 'ar' ? 'دكتوراه في اللغة العربية' : 'PhD in Arabic Language'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '15+ سنة خبرة' : '15+ years experience'}
                  specialty={language === 'ar' ? 'تعليم العربية للناطقين بغيرها' : 'Arabic for Non-native Speakers'}
                  rating={4.8}
                />
                
                <TeacherCard 
                  name={language === 'ar' ? 'الشيخ عبدالرحمن سعيد' : 'Sheikh Abdulrahman Saeed'}
                  title={language === 'ar' ? 'ماجستير في التفسير وعلوم القرآن' : 'Masters in Tafsir & Quranic Sciences'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '12+ سنة خبرة' : '12+ years experience'}
                  specialty={language === 'ar' ? 'التجويد والتلاوة' : 'Tajweed & Recitation'}
                  rating={4.9}
                />
                
                <TeacherCard 
                  name={language === 'ar' ? 'أ. نورة الفهد' : 'Ms. Noura Al-Fahd'}
                  title={language === 'ar' ? 'متخصصة في تعليم الأطفال' : 'Specialized in Children\'s Education'}
                  image="/api/placeholder/150/150"
                  experience={language === 'ar' ? '10+ سنة خبرة' : '10+ years experience'}
                  specialty={language === 'ar' ? 'تحفيظ القرآن للأطفال' : 'Quran Memorization for Children'}
                  rating={4.7}
                />
              </div>
              
              <div className="text-center mt-10">
                <button className="bg-transparent hover:bg-white/10 text-accent-base border border-accent-base hover:border-accent-bright font-bold py-2 px-6 rounded-lg transition-all transform hover:scale-105">
                  {language === 'ar' ? 'عرض جميع المعلمين' : 'View All Teachers'}
                  <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* Featured Courses Section */}
        <section id="courses" className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'الدورات المميزة' : 'Featured Courses'} 
              subtitle={language === 'ar' 
                ? 'دورات عالية الجودة مصممة لتلبية احتياجات الطلاب المختلفة' 
                : 'High-quality courses designed to meet the diverse needs of students'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              <CourseCard 
                title={language === 'ar' ? 'أساسيات التجويد للمبتدئين' : 'Tajweed Basics for Beginners'}
                instructor={language === 'ar' ? 'الشيخ عبدالرحمن سعيد' : 'Sheikh Abdulrahman Saeed'}
                image="/api/placeholder/400/250"
                level={language === 'ar' ? 'مبتدئ' : 'Beginner'}
                duration={language === 'ar' ? '12 أسبوع' : '12 weeks'}
                rating={4.8}
                students={342}
                price="99"
                discount="79"
                language={language}
              />
              
              <CourseCard 
                title={language === 'ar' ? 'العربية المعاصرة - المستوى الأول' : 'Modern Arabic - Level 1'}
                instructor={language === 'ar' ? 'د. فاطمة العبدالله' : 'Dr. Fatima Al-Abdullah'}
                image="/api/placeholder/400/250"
                level={language === 'ar' ? 'مبتدئ' : 'Beginner'}
                duration={language === 'ar' ? '16 أسبوع' : '16 weeks'}
                rating={4.9}
                students={520}
                price="129"
                discount="99"
                language={language}
              />
              
              <CourseCard 
                title={language === 'ar' ? 'حفظ جزء عم بالإتقان' : 'Memorize Juz\' Amma with Perfection'}
                instructor={language === 'ar' ? 'الشيخ أحمد محمد' : 'Sheikh Ahmad Mohammad'}
                image="/api/placeholder/400/250"
                level={language === 'ar' ? 'جميع المستويات' : 'All Levels'}
                duration={language === 'ar' ? '10 أسابيع' : '10 weeks'}
                rating={4.9}
                students={631}
                price="89"
                discount="69"
                language={language}
              />
            </div>
            
            <div className="text-center mt-10">
              <button className="bg-transparent hover:bg-white/10 text-accent-base border border-accent-base hover:border-accent-bright font-bold py-2 px-6 rounded-lg transition-all transform hover:scale-105">
                {language === 'ar' ? 'استكشف جميع الدورات' : 'Explore All Courses'}
                <i className={`fas fa-arrow-${language === 'ar' ? 'left' : 'right'} ml-2`}></i>
              </button>
            </div>
          </div>
        </section>

        {/* Learning Features Section */}
        <section className="py-16 bg-gradient-to-br from-primary-dark to-primary-dark/80 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <SectionHeader 
              title={language === 'ar' ? 'مميزات التعلم معنا' : 'Our Learning Features'} 
              subtitle={language === 'ar' 
                ? 'نوفر تجربة تعليمية فريدة تجمع بين الأصالة والتقنية الحديثة' 
                : 'We provide a unique learning experience that combines authenticity and modern technology'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              <FeatureCard 
                icon="fa-video"
                title={language === 'ar' ? 'دروس مباشرة تفاعلية' : 'Interactive Live Lessons'}
                description={language === 'ar'
                  ? 'جلسات تعليمية مباشرة مع المعلم مع إمكانية التفاعل والمشاركة والأسئلة'
                  : 'Live educational sessions with the teacher with the ability to interact, participate, and ask questions'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-graduation-cap"
                title={language === 'ar' ? 'شهادات معتمدة' : 'Accredited Certificates'}
                description={language === 'ar'
                  ? 'شهادات إتمام معتمدة لجميع الدورات مع سلاسل إسناد للقراءات المختلفة'
                  : 'Accredited completion certificates for all courses with chains of narration for different readings'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-users"
                title={language === 'ar' ? 'حلقات تعلم جماعية' : 'Group Learning Circles'}
                description={language === 'ar'
                  ? 'حلقات تعليمية مصغرة تتيح التعلم في مجموعات مع زملاء ذوي اهتمامات متشابهة'
                  : 'Small educational circles that allow learning in groups with peers of similar interests'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-book-reader"
                title={language === 'ar' ? 'محتوى تعليمي متكامل' : 'Comprehensive Learning Content'}
                description={language === 'ar'
                  ? 'محتوى تعليمي شامل يتضمن الفيديوهات والكتب الإلكترونية والتمارين التفاعلية'
                  : 'Comprehensive educational content including videos, e-books, and interactive exercises'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-mobile-alt"
                title={language === 'ar' ? 'تطبيق رَتِّل للتعلم الذاتي' : 'Rateel App for Self-Learning'}
                description={language === 'ar'
                  ? 'تطبيق خاص للتعلم الذاتي ومتابعة التقدم وممارسة التجويد والتلاوة'
                  : 'A special app for self-learning, progress tracking, and practicing Tajweed and recitation'
                }
                language={language}
              />
              
              <FeatureCard 
                icon="fa-chart-line"
                title={language === 'ar' ? 'نظام متابعة التقدم' : 'Progress Tracking System'}
                description={language === 'ar'
                  ? 'نظام ذكي لمتابعة تقدم الطالب وتقييم الأداء وتوفير التغذية الراجعة المستمرة'
                  : 'Smart system for tracking student progress, evaluating performance, and providing continuous feedback'
                }
                language={language}
              />
            </div>
          </div>
        </section>

        {/* Pricing Section */}
        <section id="pricing" className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'خطط الاشتراك' : 'Subscription Plans'} 
              subtitle={language === 'ar' 
                ? 'اختر الخطة المناسبة لاحتياجاتك التعليمية وميزانيتك' 
                : 'Choose the plan that suits your educational needs and budget'
              } 
            />
            
            <div className="flex flex-wrap justify-center gap-8 mt-12">
              <PricingCard 
                title={language === 'ar' ? 'الباقة الأساسية' : 'Basic Package'}
                price="39"
                period={language === 'ar' ? 'شهرياً' : 'per month'}
                description={language === 'ar'
                  ? 'مناسبة للمبتدئين الراغبين في استكشاف المنصة'
                  : 'Suitable for beginners who want to explore the platform'
                }
                features={language === 'ar'
                  ? [
                      'حصتان أسبوعياً',
                      'معلم متخصص',
                      'منتدى للمناقشة',
                      'مكتبة المحتوى الأساسية',
                      'شهادة إتمام',
                    ]
                  : [
                      '2 Sessions per week',
                      'Specialized teacher',
                      'Discussion forum',
                      'Basic content library',
                      'Completion certificate',
                    ]
                }
                buttonText={language === 'ar' ? 'ابدأ الآن' : 'Get Started'}
                language={language}
                isPopular={false}
              />
              
              <PricingCard 
                title={language === 'ar' ? 'الباقة المتقدمة' : 'Advanced Package'}
                price="79"
                period={language === 'ar' ? 'شهرياً' : 'per month'}
                description={language === 'ar'
                  ? 'الخيار الأمثل لمعظم الطلاب بميزات متوازنة'
                  : 'The optimal choice for most students with balanced features'
                }
                features={language === 'ar'
                  ? [
                      '4 حصص أسبوعياً',
                      'معلم متخصص',
                      'جلسات فردية وجماعية',
                      'المكتبة الكاملة للمحتوى',
                      'تطبيق رتل المتكامل',
                      'شهادة معتمدة',
                      'دعم فني على مدار الساعة',
                    ]
                  : [
                      '4 Sessions per week',
                      'Specialized teacher',
                      'Individual & group sessions',
                      'Full content library',
                      'Integrated Rateel app',
                      'Accredited certificate',
                      '24/7 Technical support',
                    ]
                }
                buttonText={language === 'ar' ? 'اشترك الآن' : 'Subscribe Now'}
                language={language}
                isPopular={true}
              />
              
              <PricingCard 
                title={language === 'ar' ? 'الباقة الاحترافية' : 'Professional Package'}
                price="129"
                period={language === 'ar' ? 'شهرياً' : 'per month'}
                description={language === 'ar'
                  ? 'للطلاب الجادين الراغبين في تعلم مكثف ومخصص'
                  : 'For serious students who want intensive and personalized learning'
                }
                features={language === 'ar'
                  ? [
                      'حصص يومية مفتوحة',
                      'معلم خاص',
                      'خطة تعليمية مخصصة',
                      'جميع ميزات الباقة المتقدمة',
                      'جلسات تقييم منتظمة',
                      'إجازات معتمدة بالأسانيد',
                      'دعم بحثي وعلمي متكامل',
                    ]
                  : [
                      'Daily open sessions',
                      'Private teacher',
                      'Customized learning plan',
                      'All Advanced package features',
                      'Regular assessment sessions',
                      'Accredited Ijazat with Isnad',
                      'Comprehensive research support',
                    ]
                }
                buttonText={language === 'ar' ? 'اشترك الآن' : 'Subscribe Now'}
                language={language}
                isPopular={false}
              />
            </div>
            
            {/* Family Plan Banner */}
            <div className="mt-12 bg-accent-base/20 p-6 rounded-xl border border-accent-base/40">
              <div className="flex flex-wrap items-center justify-between">
                <div className="mb-4 md:mb-0">
                  <h3 className="text-xl font-bold text-accent-base mb-2">
                    {language === 'ar' ? 'باقة العائلة المميزة' : 'Special Family Package'}
                  </h3>
                  <p className="text-gray-300">
                    {language === 'ar'
                      ? 'اشترك لأفراد عائلتك واحصل على خصم 15% لكل فرد إضافي!'
                      : 'Subscribe for your family members and get a 15% discount for each additional member!'
                    }
                  </p>
                </div>
                <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-2 px-5 rounded-lg transition-all">
                  {language === 'ar' ? 'تفاصيل الباقة العائلية' : 'Family Package Details'}
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* App Showcase Section */}
        <section id="app" className="py-16 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <SectionHeader 
              title={language === 'ar' ? 'تطبيق رَتِّل للتعلم الذاتي' : 'Rateel App for Self-Learning'} 
              subtitle={language === 'ar' 
                ? 'التطبيق المساعد الأمثل لممارسة التجويد والتلاوة بتقنيات الذكاء الاصطناعي' 
                : 'The ideal assistant app for practicing Tajweed and recitation with AI technologies'
              } 
            />
            
            <div className="flex flex-wrap items-center mt-12 gap-12">
              <div className="w-full lg:w-5/12">
                <h3 className="text-3xl font-bold mb-6 text-accent-base">
                  {language === 'ar' ? 'تعلم التجويد بطريقة مبتكرة' : 'Learn Tajweed in an Innovative Way'}
                </h3>
                
                <div className="space-y-6">
                  <AppFeatureItem 
                    icon="fa-microphone"
                    title={language === 'ar' ? 'تصحيح التلاوة بالذكاء الاصطناعي' : 'AI Recitation Correction'}
                    description={language === 'ar'
                      ? 'تقنية متطورة للاستماع لتلاوتك وتحديد الأخطاء وتقديم الملاحظات لتحسين الأداء'
                      : 'Advanced technology to listen to your recitation, identify errors, and provide feedback to improve performance'
                    }
                    language={language}
                  />
                  
                  <AppFeatureItem 
                    icon="fa-book-open"
                    title={language === 'ar' ? 'دروس تفاعلية للتجويد' : 'Interactive Tajweed Lessons'}
                    description={language === 'ar'
                      ? 'تعلم قواعد التجويد خطوة بخطوة مع أمثلة توضيحية وتمارين تطبيقية'
                      : 'Learn Tajweed rules step by step with illustrative examples and practical exercises'
                    }
                    language={language}
                  />
                  
                  <AppFeatureItem 
                    icon="fa-trophy"
                    title={language === 'ar' ? 'نظام تحفيزي متكامل' : 'Integrated Motivational System'}
                    description={language === 'ar'
                      ? 'اكسب النقاط والإنجازات وارتق في المستويات كلما تقدمت في رحلة التعلم'
                      : 'Earn points and achievements and advance in levels as you progress in your learning journey'
                    }
                    language={language}
                  />
                  
                  <AppFeatureItem 
                    icon="fa-sync"
                    title={language === 'ar' ? 'مزامنة مع الدروس الحية' : 'Synchronization with Live Lessons'}
                    description={language === 'ar'
                      ? 'يتكامل التطبيق مع دروسك في الأكاديمية لتتبع تقدمك ومراجعة ما تم دراسته'
                      : 'The app integrates with your academy lessons to track your progress and review what you\'ve studied'
                    }
                    language={language}
                  />
                </div>
                
                <div className="mt-8 flex gap-4">
                  <button className="bg-black hover:bg-black/80 text-white font-bold py-2 px-4 rounded-lg transition-all flex items-center">
                    <i className="fab fa-apple text-2xl mr-2"></i>
                    <div className="text-left">
                      <div className="text-xs">{language === 'ar' ? 'متوفر على' : 'Available on'}</div>
                      <div>App Store</div>
                    </div>
                  </button>
                  
                  <button className="bg-black hover:bg-black/80 text-white font-bold py-2 px-4 rounded-lg transition-all flex items-center">
                    <i className="fab fa-google-play text-2xl mr-2"></i>
                    <div className="text-left">
                      <div className="text-xs">{language === 'ar' ? 'متوفر على' : 'Available on'}</div>
                      <div>Google Play</div>
                    </div>
                  </button>
                </div>
              </div>
              
              <div className="w-full lg:w-5/12 lg:ml-auto">
                <div className="relative">
                  {/* App Screenshots */}
                  <div className="relative z-10 transform rotate-3 hover:rotate-0 transition-transform duration-500">
                    <img 
                      src="/api/placeholder/500/300" 
                      alt="Rateel App Interface" 
                      className="rounded-xl shadow-2xl border-4 border-white/10"
                    />
                  </div>
                  
                  <div className="absolute -bottom-10 -left-10 z-0 transform -rotate-6 hover:rotate-0 transition-transform duration-500">
                    <img 
                      src="/api/placeholder/400/250" 
                      alt="Rateel App Feature" 
                      className="rounded-xl shadow-2xl border-4 border-white/10"
                    />
                  </div>
                  
                  {/* App Stats */}
                  <div className="absolute top-10 -right-5 bg-accent-base text-primary-dark p-4 rounded-lg transform rotate-6 shadow-lg z-20">
                    <div className="font-bold text-xl">100K+</div>
                    <div className="text-sm">{language === 'ar' ? 'تنزيل' : 'Downloads'}</div>
                  </div>
                  
                  <div className="absolute -bottom-5 right-20 bg-white text-primary-dark p-4 rounded-lg transform -rotate-3 shadow-lg z-20">
                    <div className="font-bold text-xl">4.8/5</div>
                    <div className="flex text-accent-base">
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star"></i>
                      <i className="fas fa-star-half-alt"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Testimonials Section */}
        <section className="py-16 bg-primary-base/50">
          <div className="container mx-auto px-4">
            <SectionHeader 
              title={language === 'ar' ? 'آراء طلابنا' : 'Student Testimonials'} 
              subtitle={language === 'ar' 
                ? 'استمع إلى تجارب طلابنا وقصص نجاحهم مع أكاديمية رتل' 
                : 'Listen to our students\' experiences and success stories with Rateel Academy'
              } 
            />
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
              <TestimonialCard 
                name={language === 'ar' ? 'محمد العتيبي' : 'Mohammed Al-Otaibi'}
                location={language === 'ar' ? 'الرياض، السعودية' : 'Riyadh, Saudi Arabia'}
                image="/api/placeholder/80/80"
                testimonial={language === 'ar'
                  ? 'بفضل أكاديمية رتل، تمكنت من حفظ 15 جزءاً من القرآن الكريم خلال عام واحد مع إتقان التجويد. المعلمون متميزون والمنهجية رائعة!'
                  : 'Thanks to Rateel Academy, I was able to memorize 15 parts of the Quran in one year with mastery of Tajweed. The teachers are excellent and the methodology is wonderful!'
                }
                language={language}
                course={language === 'ar' ? 'برنامج حفظ القرآن' : 'Quran Memorization Program'}
              />
              
              <TestimonialCard 
                name={language === 'ar' ? 'سارة الزهراني' : 'Sarah Al-Zahrani'}
                location={language === 'ar' ? 'دبي، الإمارات' : 'Dubai, UAE'}
                image="/api/placeholder/80/80"
                testimonial={language === 'ar'
                  ? 'كنت أبحث عن معلمة متخصصة لمساعدتي في تحسين تلاوتي، وفي رتل وجدت أفضل منصة. التعلم عن بعد مرن ومناسب لجدولي المزدحم.'
                  : 'I was looking for a specialized teacher to help me improve my recitation, and in Rateel I found the best platform. Distance learning is flexible and suitable for my busy schedule.'
                }
                language={language}
                course={language === 'ar' ? 'إتقان التجويد' : 'Tajweed Mastery'}
              />
              
              <TestimonialCard 
                name={language === 'ar' ? 'أحمد البلوشي' : 'Ahmed Al-Balushi'}
                location={language === 'ar' ? 'مسقط، عمان' : 'Muscat, Oman'}
                image="/api/placeholder/80/80"
                testimonial={language === 'ar'
                  ? 'كمبتدئ في تعلم اللغة العربية، كنت متردداً في البداية، لكن المنهج التدريجي والمعلمين الصبورين ساعدوني كثيراً. الآن أستطيع التحدث وقراءة القرآن بشكل أفضل.'
                  : 'As a beginner in learning Arabic, I was hesitant at first, but the gradual curriculum and patient teachers helped me a lot. Now I can speak and read the Quran better.'
                }
                language={language}
                course={language === 'ar' ? 'اللغة العربية للمبتدئين' : 'Arabic for Beginners'}
              />
            </div>
            
            {/* Video Testimonial */}
            <div className="mt-12 bg-primary-dark/60 p-6 rounded-xl">
              <div className="flex flex-wrap items-center gap-8">
                <div className="w-full lg:w-1/3">
                  <h3 className="text-2xl font-bold mb-4 text-accent-base">
                    {language === 'ar' ? 'قصص نجاح مع رتل' : 'Success Stories with Rateel'}
                  </h3>
                  <p className="text-gray-300 mb-6">
                    {language === 'ar'
                      ? 'استمع إلى قصص حقيقية من طلابنا حول كيف ساعدتهم أكاديمية رتل في تحقيق أهدافهم في تعلم القرآن واللغة العربية.'
                      : 'Listen to real stories from our students about how Rateel Academy helped them achieve their goals in learning the Quran and Arabic language.'
                    }
                  </p>
                  <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-2 px-5 rounded-lg transition-all">
                    {language === 'ar' ? 'مشاهدة المزيد من القصص' : 'Watch More Stories'}
                  </button>
                </div>
                
                <div className="w-full lg:w-3/5 lg:ml-auto">
                  <div className="relative overflow-hidden rounded-xl cursor-pointer group">
                    <img 
                      src="/api/placeholder/800/450" 
                      alt="Student Success Story" 
                      className="w-full h-auto rounded-xl transition-transform group-hover:scale-105"
                    />
                    <div className="absolute inset-0 flex items-center justify-center bg-black/40 group-hover:bg-black/50 transition-all">
                      <div className="bg-accent-base/90 text-primary-dark rounded-full w-16 h-16 flex items-center justify-center transform group-hover:scale-110 transition-transform">
                        <i className="fas fa-play text-xl"></i>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 bg-gradient-to-br from-accent-base/30 to-accent-dark/20 relative">
          {/* Decorative Pattern Background */}
          <div className="absolute inset-0 opacity-5 bg-islamic-pattern z-0"></div>
          
          <div className="container mx-auto px-4 relative z-10">
            <div className="text-center max-w-3xl mx-auto">
              <h2 className="text-3xl md:text-4xl font-bold mb-6 text-accent-base">
                {language === 'ar' 
                  ? 'ابدأ رحلتك التعليمية مع أكاديمية رَتِّل اليوم' 
                  : 'Start Your Learning Journey with Rateel Academy Today'
                }
              </h2>
              <p className="text-xl text-gray-300 mb-8">
                {language === 'ar'
                  ? 'انضم إلى الآلاف من الطلاب حول العالم واستفد من تجربة تعليمية فريدة مع نخبة من المعلمين المتخصصين'
                  : 'Join thousands of students around the world and benefit from a unique educational experience with elite specialized teachers'
                }
              </p>
              
              <div className="flex flex-wrap justify-center gap-4">
                <button className="bg-accent-base hover:bg-accent-bright text-primary-dark font-bold py-3 px-8 rounded-lg transition-all transform hover:scale-105">
                  {language === 'ar' ? 'سجل الآن' : 'Register Now'}
                </button>
                <button className="bg-transparent hover:bg-white/10 border border-accent-base text-accent-base font-bold py-3 px-8 rounded-lg transition-all transform hover:scale-105">
                  {language === 'ar' ? 'جلسة تجريبية مجانية' : 'Free Trial Session'}
                </button>
              </div>
              
              <div className="mt-10 flex justify-center gap-10 flex-wrap">
                <div className="flex items-center">
                  <i className="fas fa-check-circle text-accent-base text-xl mr-2"></i>
                  <span className="text-gray-300">
                    {language === 'ar' ? 'استرداد كامل لمدة 14 يوماً' : '14-day full refund'}
                  </span>
                </div>
                
                <div className="flex items-center">
                  <i className="fas fa-check-circle text-accent-base text-xl mr-2"></i>
                  <span className="text-gray-300">
                    {language === 'ar' ? 'دعم فني على مدار الساعة' : '24/7 technical support'}
                  </span>
                </div>
                
                <div className="flex items-center">
                  <i className="fas fa-check-circle text-accent-base text-xl mr-2"></i>
                  <span className="text-gray-300">
                    {language === 'ar' ? 'إلغاء الاشتراك في أي وقت' : 'Cancel subscription anytime'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Contact Section */}
        <section id="contact" className="py-16 bg-primary-dark">
          <div className="container mx-auto px-4">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              <div>
                <h2 className="text-3xl font-bold mb-6 text-accent-base">
                  {language === 'ar' ? 'تواصل معنا' : 'Contact Us'}
                </h2>
                <p className="text-gray-300 mb-8">
                  {language === 'ar'
                    ? 'نحن هنا للإجابة على استفساراتك ومساعدتك في اختيار البرنامج المناسب لك'
                    : 'We\'re here to answer your inquiries and help you choose the right program for you'
                  }
                </p>
                
                <div className="space-y-6">
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-envelope text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'البريد الإلكتروني' : 'Email'}
                      </h3>
                      <p className="text-gray-300">info@rateelacademy.com</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-phone-alt text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'الهاتف' : 'Phone'}
                      </h3>
                      <p className="text-gray-300">+966 12 345 6789</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-headset text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'الدعم الفني' : 'Technical Support'}
                      </h3>
                      <p className="text-gray-300">support@rateelacademy.com</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <div className="bg-accent-base/20 p-2 rounded-full mt-1 mr-4">
                      <i className="fas fa-clock text-accent-base"></i>
                    </div>
                    <div>
                      <h3 className="font-bold text-white">
                        {language === 'ar' ? 'ساعات العمل' : 'Working Hours'}
                      </h3>
```

## Yassin (2025-05-18T18:49)

Usong same colour of rateel build an Arabic English website as Academy for learning quran and Arabic with different paths and live teachers and courses certificate and other and rateel app will be showed also there and the price packages like various Academy zadul muslimito ecc

## Claude (2025-05-18T18:50)

# Website Design: Quranic Academy with Rateel Integration

I'll create a responsive bilingual (Arabic/English) website design for a Quranic academy that matches the Rateel app's design language. This will include sections for learning paths, live teachers, courses, certificates, and pricing packages.

Let me create this for you using the Rateel app's emerald green and gold color scheme:

**Artifact: Quranic Academy Website** (`text/html`, create)

```html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>معهد النور للقرآن واللغة العربية | Al-Noor Academy for Quran & Arabic</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root {
      /* Primary colors from Rateel */
      --primary-base: #1F4037;
      --primary-light: #2D6A4F;
      --primary-dark: #0B1C17;
      --primary-gradient: linear-gradient(180deg, #1F4037 0%, #0B1C17 100%);
      
      /* Accent colors from Rateel */
      --accent-base: #DAA520;
      --accent-light: #FFD700;
      --accent-bright: #FCC200;
      --accent-glow: #FFE355;
      --accent-dark: #B8860B;
      --accent-muted: #D4AF37;
      
      /* Text colors */
      --text-light: #FFFFFF;
      --text-dark: #0B1C17;
      --text-muted: #95D5B2;
      --text-gold: #DFC298;
      
      /* Spacing */
      --spacing-xs: 0.25rem;
      --spacing-sm: 0.5rem;  
      --spacing-md: 1rem;   
      --spacing-lg: 1.5rem;  
      --spacing-xl: 2rem;   
      --spacing-xxl: 3rem;  
      
      /* Border radius */
      --border-radius-sm: 0.5rem;
      --border-radius-md: 1rem;
      --border-radius-lg: 1.25rem;
      --border-radius-xl: 1.5rem;
      --border-radius-full: 9999px;
    }
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Cairo', sans-serif;
    }
    
    body {
      background: var(--primary-gradient);
      color: var(--text-light);
      min-height: 100vh;
      overflow-x: hidden;
    }
    
    /* Background pattern similar to Rateel */
    body::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-image: url('https://i.imgur.com/8gVJXPI.png');
      background-repeat: repeat;
      background-size: 1000px;
      opacity: 0.04;
      z-index: -1;
      pointer-events: none;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 var(--spacing-md);
    }
    
    /* Header styling */
    header {
      background: rgba(0, 0, 0, 0.2);
      backdrop-
```

## Yassin (2025-05-18T18:50)

Usong same colour of rateel build an Arabic English website as Academy for learning quran and Arabic with different paths and live teachers and courses certificate and other and rateel app will be showed also there and the price packages like various Academy zadul muslimito ecc

should have same name of the app and should be super user frienldy

## Claude (2025-05-18T18:54)

# Designing an Arabic-English Website for Rateel Academy

I'll create a modern, user-friendly website for a Quran and Arabic learning academy that matches the existing Rateel app's aesthetics. The website will follow the same color scheme, feature both Arabic and English content, and showcase learning paths, live teachers, certificates, and pricing packages.

Let me create this as a responsive React component that captures the essence of the Rateel brand:

**Artifact: Rateel Academy Website** (`application/vnd.ant.react`, create)

```jsx
import React, { useState } from 'react';
import { ChevronRight, ChevronLeft, CheckCircle, Award, Users, Book, Mic, Certificate, Globe, Star, Menu, X } from 'lucide-react';

export default function RateelAcademy() {
  const [language, setLanguage] = useState('english'); // 'english' or 'arabic'
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  const toggleLanguage = () => {
    setLanguage(language === 'english' ? 'arabic' : 'english');
  };
  
  const toggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };
  
  const isArabic = language === 'arabic';
  
  const learningPaths = [
    {
      title: isArabic ? 'تعلم القرآن الكريم' : 'Quran Learning',
      description: isArabic ? 'دروس في التلاوة والتجويد والحفظ مع معلمين متخصصين' : 'Lessons in recitation, tajweed and memorization with specialized teachers',
      icon: <Book className="h-8 w-8" />,
      features: isArabic ? ['التجويد', 'الحفظ', 'التفسير'] : ['Tajweed', 'Memorization', 'Tafsir']
    },
    {
      title: isArabic ? 'تعلم اللغة العربية' : 'Arabic Language',
      description: isArabic ? 'تعلم اللغة العربية من المستوى المبتدئ إلى المتقدم' : 'Learn Arabic from beginner to advanced level',
      icon: <Globe className="h-8 w-8" />,
      features: isArabic ? ['النحو', 'الصرف', 'المحادثة'] : ['Grammar', 'Vocabulary', 'Conversation'] 
    },
    {
      title: isArabic ? 'الإجازات والشهادات' : 'Certificates & Ijazah',
      description: isArabic ? 'احصل على شهادات معتمدة وإجازات في القراءات' : 'Get certified with recognized certificates and Ijazah in Qira\'at',
      icon: <Certificate className="h-8 w-8" />,
      features: isArabic ? ['إجازة حفص', 'إجازات القراءات', 'شهادات معتمدة'] : ['Hafs Ijazah', 'Qira\'at Ijazahs', 'Certified Diplomas']
    },
    {
      title: isArabic ? 'التدريب الصوتي' : 'Voice Training',
      description: isArabic ? 'تدريب صوتي متخصص لتحسين تلاوتك ومخارج الحروف' : 'Specialized voice training to improve your recitation and pronunciation',
      icon: <Mic className="h-8 w-8" />,
      features: isArabic ? ['مخارج الحروف', 'الصفات', 'تقويم اللسان'] : ['Pronunciation', 'Characteristics', 'Tongue Training']
    }
  ];
  
  const teachers = [
    {
      name: isArabic ? 'الشيخ عبدالله محمد' : 'Sheikh Abdullah Muhammad',
      role: isArabic ? 'أستاذ القراءات والتجويد' : 'Professor of Qira\'at & Tajweed',
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fit=crop&w=800&q=80',
      rating: 4.9
    },
    {
      name: isArabic ? 'الأستاذة نور أحمد' : 'Ustadha Noor Ahmed',
      role: isArabic ? 'معلمة اللغة العربية والتفسير' : 'Arabic Language & Tafsir Teacher',
      image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?fit=crop&w=800&q=80',
      rating: 4.8
    },
    {
      name: isArabic ? 'الشيخ محمد علي' : 'Sheikh Muhammad Ali',
      role: isArabic ? 'حافظ ومجاز بالقراءات العشر' : 'Hafiz & Certified in 10 Qira\'at',
      image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?fit=crop&w=800&q=80',
      rating: 4.9
    }
  ];
  
  const pricingPlans = [
    {
      title: isArabic ? 'الباقة الأساسية' : 'Essential Plan',
      price: isArabic ? '٣٩' : '39',
      period: isArabic ? 'شهرياً' : 'per month',
      features: isArabic 
        ? ['درسان أسبوعياً', 'تطبيق رتل مجاناً', 'دعم فني', 'تقارير تقدم شهرية'] 
        : ['2 Classes Weekly', 'Free Rateel App', 'Technical Support', 'Monthly Progress Reports'],
      cta: isArabic ? 'اشترك الآن' : 'Subscribe Now',
      popular: false
    },
    {
      title: isArabic ? 'الباقة المميزة' : 'Premium Plan',
      price: isArabic ? '٦٩' : '69',
      period: isArabic ? 'شهرياً' : 'per month',
      features: isArabic 
        ? ['٤ دروس أسبوعياً', 'تطبيق رتل مجاناً', 'دعم فني على مدار الساعة', 'تقارير تقدم أسبوعية', 'جلسات فردية'] 
        : ['4 Classes Weekly', 'Free Rateel App', '24/7 Technical Support', 'Weekly Progress Reports', 'One-on-One Sessions'],
      cta: isArabic ? 'اشترك الآن' : 'Subscribe Now',
      popular: true
    },
    {
      title: isArabic ? 'باقة العائلة' : 'Family Plan',
      price: isArabic ? '٩٩' : '99',
      period: isArabic ? 'شهرياً' : 'per month',
      features: isArabic 
        ? ['حتى ٣ أفراد', '٦ دروس أسبوعياً', 'تطبيق رتل مجاناً', 'دعم فني على مدار الساعة', 'تقارير تقدم أسبوعية', 'جلسات فردية'] 
        : ['Up to 3 Family Members', '6 Classes Weekly', 'Free Rateel App', '24/7 Technical Support', 'Weekly Progress Reports', 'One-on-One Sessions'],
      cta: isArabic ? 'اشترك الآن' : 'Subscribe Now',
      popular: false
    }
  ];
  
  const testimonials = [
    {
      quote: isArabic 
        ? 'تجربة تعليمية رائعة! تحسنت تلاوتي بشكل كبير مع المعلمين المتميزين في أكاديمية رتل.' 
        : 'Amazing learning experience! My recitation has improved significantly with the excellent teachers at Rateel Academy.',
      name: isArabic ? 'أحمد محمود' : 'Ahmed Mahmoud',
      location: isArabic ? 'مصر' : 'Egypt'
    },
    {
      quote: isArabic 
        ? 'كوني أماً لثلاثة أطفال، وجدت في باقة العائلة الحل الأمثل لتعليم أطفالي القرآن واللغة العربية من المنزل.' 
        : 'As a mother of three, the family plan was the perfect solution for teaching my children Quran and Arabic from home.',
      name: isArabic ? 'فاطمة علي' : 'Fatima Ali',
      location: isArabic ? 'الإمارات' : 'UAE'
    },
    {
      quote: isArabic 
        ? 'تطبيق رتل المرفق مع الدروس الحية يساعدني على المراجعة والتدرب في أي وقت.' 
        : 'The Rateel app that comes with the live lessons helps me review and practice anytime.',
      name: isArabic ? 'محمد عبدالله' : 'Mohammed Abdullah',
      location: isArabic ? 'المملكة المتحدة' : 'United Kingdom'
    }
  ];

  return (
    <div dir={isArabic ? 'rtl' : 'ltr'} className={`min-h-screen font-sans ${isArabic ? 'font-arabic' : ''}`}>
      {/* Header */}
      <header className="bg-gradient-to-r from-emerald-900 to-green-800 text-white shadow-lg">
        <div className="container mx-auto px-4 py-3">
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="text-2xl font-bold mr-2">
                {isArabic ? 'أكاديمية رَتِّلِ' : 'Rateel Academy'}
              </div>
            </div>
            
            {/* Desktop Menu */}
            <nav className="hidden md:flex items-center space-x-6">
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'الرئيسية' : 'Home'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'المسارات' : 'Paths'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'المعلمون' : 'Teachers'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'الباقات' : 'Pricing'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'التطبيق' : 'App'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'تواصل معنا' : 'Contact'}</a>
              <button 
                onClick={toggleLanguage}
                className="bg-transparent border border-gold-400 text-gold-400 px-4 py-2 rounded-lg hover:bg-gold-400 hover:text-emerald-900 transition"
              >
                {isArabic ? 'English' : 'العربية'}
              </button>
            </nav>
            
            {/* Mobile Menu Button */}
            <div className="md:hidden flex items-center">
              <button onClick={toggleLanguage} className="mr-4 text-gold-400">
                {isArabic ? 'EN' : 'AR'}
              </button>
              <button onClick={toggleMobileMenu} className="text-white">
                {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
              </button>
            </div>
          </div>
          
          {/* Mobile Menu */}
          {mobileMenuOpen && (
            <nav className="md:hidden pt-4 pb-2 space-y-2">
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'الرئيسية' : 'Home'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'المسارات' : 'Paths'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'المعلمون' : 'Teachers'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'الباقات' : 'Pricing'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'التطبيق' : 'App'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'تواصل معنا' : 'Contact'}</a>
            </nav>
          )}
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-emerald-900 via-green-800 to-emerald-950 text-white py-16">
        <div className="absolute inset-0 opacity-10 bg-[url('https://i.imgur.com/XdJI2uU.png')] bg-repeat"></div>
        <div className="container mx-auto px-4 relative z-10">
          <div className="flex flex-col md:flex-row items-center">
            <div className="md:w-1/2 mb-10 md:mb-0">
              <h1 className="text-4xl md:text-5xl font-bold mb-4">
                {isArabic ? 'تعلم القرآن واللغة العربية مع أفضل المعلمين' : 'Learn Quran & Arabic with Expert Teachers'}
              </h1>
              <p className="text-lg mb-8 text-gray-200">
                {isArabic 
                  ? 'دروس مباشرة، تطبيق تفاعلي، وشهادات معتمدة - رحلة تعليمية متكاملة من منزلك مع أكاديمية رتل'
                  : 'Live classes, interactive app, and certified credentials - a complete learning journey from your home with Rateel Academy'}
              </p>
              <div className="flex flex-wrap gap-4">
                <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 font-bold py-3 px-6 rounded-lg transition">
                  {isArabic ? 'ابدأ الآن' : 'Get Started'}
                </button>
                <button className="bg-transparent border-2 border-white hover:bg-white hover:text-emerald-900 font-bold py-3 px-6 rounded-lg transition">
                  {isArabic ? 'تجربة مجانية' : 'Free Trial'}
                </button>
              </div>
            </div>
            <div className="md:w-1/2 flex justify-center">
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-gold-400 to-gold-600 rounded-2xl blur opacity-30"></div>
                <div className="relative bg-emerald-950/70 p-2 rounded-2xl overflow-hidden">
                  <img 
                    src="https://i.imgur.com/S0dxjjK.jpg" 
                    alt="Quran Learning" 
                    className="rounded-xl w-full max-w-md"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Learning Paths */}
      <section className="py-16 bg-emerald-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-emerald-900 mb-2">
              {isArabic ? 'مسارات التعلم' : 'Learning Paths'}
            </h2>
            <p className="text-emerald-700">
              {isArabic ? 'اختر المسار المناسب لك وابدأ رحلتك التعليمية' : 'Choose your perfect path and start your learning journey'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {learningPaths.map((path, index) => (
              <div key={index} className="bg-white rounded-xl shadow-md hover:shadow-lg transition p-6 border-t-4 border-gold-500">
                <div className="text-gold-500 mb-4">
                  {path.icon}
                </div>
                <h3 className="text-xl font-bold text-emerald-900 mb-2">{path.title}</h3>
                <p className="text-emerald-700 mb-4">{path.description}</p>
                <ul className="space-y-2">
                  {path.features.map((feature, i) => (
                    <li key={i} className="flex items-center text-emerald-700">
                      <CheckCircle className="h-4 w-4 text-emerald-600 mr-2" />
                      <span>{feature}</span>
                    </li>
                  ))}
                </ul>
                <button className="mt-6 w-full py-2 px-4 bg-emerald-100 text-emerald-700 rounded-lg hover:bg-emerald-200 transition">
                  {isArabic ? 'اكتشف المزيد' : 'Learn More'}
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* App Showcase */}
      <section className="py-16 bg-gradient-to-br from-emerald-900 to-green-800 text-white relative overflow-hidden">
        <div className="absolute inset-0 opacity-5 bg-[url('https://i.imgur.com/XdJI2uU.png')] bg-repeat"></div>
        <div className="container mx-auto px-4 relative z-10">
          <div className="flex flex-col md:flex-row items-center">
            <div className="md:w-1/2 mb-10 md:mb-0">
              <h2 className="text-3xl font-bold mb-4">
                {isArabic ? 'تطبيق رَتِّلِ - مساعدك الشخصي في رحلة التعلم' : 'Rateel App - Your Personal Learning Assistant'}
              </h2>
              <p className="text-lg mb-6">
                {isArabic 
                  ? 'استكمل رحلتك التعليمية مع تطبيق رتل المتاح لجميع المشتركين. تدرب على التجويد، تتبع تقدمك، وحسن أدائك بين دروسك المباشرة.'
                  : 'Complete your learning journey with the Rateel app included for all subscribers. Practice tajweed, track your progress, and improve between your live classes.'}
              </p>
              <div className="space-y-4">
                <div className="flex items-start">
                  <div className="bg-gold-500 p-2 rounded-full text-emerald-900 mr-3">
                    <Award className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold">{isArabic ? 'تقييم صوتي متقدم' : 'Advanced Voice Evaluation'}</h3>
                    <p className="text-gray-200">{isArabic ? 'تقييم فوري لتلاوتك وقراءتك' : 'Instant feedback on your recitation'}</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <div className="bg-gold-500 p-2 rounded-full text-emerald-900 mr-3">
                    <Book className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold">{isArabic ? 'دروس تفاعلية' : 'Interactive Lessons'}</h3>
                    <p className="text-gray-200">{isArabic ? 'مسارات تعليمية مخصصة لكل مستوى' : 'Customized learning paths for every level'}</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <div className="bg-gold-500 p-2 rounded-full text-emerald-900 mr-3">
                    <Users className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold">{isArabic ? 'متوافق مع دروسك المباشرة' : 'Synchronized with Live Classes'}</h3>
                    <p className="text-gray-200">{isArabic ? 'اطلع معلمك على تقدمك في التطبيق' : 'Your teacher can review your app progress'}</p>
                  </div>
                </div>
              </div>
              <div className="mt-8">
                <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 font-bold py-3 px-6 rounded-lg transition">
                  {isArabic ? 'تحميل التطبيق' : 'Download App'}
                </button>
              </div>
            </div>
            <div className="md:w-1/2 flex justify-center">
              <div className="relative w-72">
                <div className="absolute -inset-1 bg-gradient-to-r from-gold-400 to-gold-600 rounded-[32px] blur opacity-30"></div>
                <div className="relative">
                  <img 
                    src="https://i.imgur.com/KBTjiPp.png" 
                    alt="Rateel App" 
                    className="w-full relative z-10"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Teachers */}
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-emerald-900 mb-2">
              {isArabic ? 'نخبة من المعلمين' : 'Our Expert Teachers'}
            </h2>
            <p className="text-emerald-700">
              {isArabic ? 'تعلم مع أفضل المعلمين المؤهلين والمجازين' : 'Learn with the best qualified and certified teachers'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {teachers.map((teacher, index) => (
              <div key={index} className="bg-white rounded-xl shadow-md hover:shadow-lg transition overflow-hidden">
                <div className="h-56 overflow-hidden relative">
                  <img 
                    src={teacher.image} 
                    alt={teacher.name} 
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4">
                    <div className="flex items-center">
                      <div className="bg-gold-500 text-emerald-900 rounded-full py-1 px-3 text-sm font-bold flex items-center">
                        <Star className="h-3 w-3 mr-1" fill="currentColor" />
                        {teacher.rating}
                      </div>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  <h3 className="text-xl font-bold text-emerald-900 mb-1">{teacher.name}</h3>
                  <p className="text-emerald-700 mb-4">{teacher.role}</p>
                  <button className="w-full py-2 px-4 border border-emerald-600 text-emerald-600 rounded-lg hover:bg-emerald-50 transition">
                    {isArabic ? 'عرض الملف الشخصي' : 'View Profile'}
                  </button>
                </div>
              </div>
            ))}
          </div>
          
          <div className="mt-12 text-center">
            <button className="bg-emerald-100 hover:bg-emerald-200 text-emerald-700 font-bold py-3 px-6 rounded-lg transition inline-flex items-center">
              {isArabic ? 'عرض كافة المعلمين' : 'View All Teachers'} 
              {isArabic ? <ChevronLeft className="h-5 w-5 ml-1" /> : <ChevronRight className="h-5 w-5 ml-1" />}
            </button>
          </div>
        </div>
      </section>

      {/* Pricing Plans */}
      <section className="py-16 bg-emerald-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-emerald-900 mb-2">
              {isArabic ? 'باقات الاشتراك' : 'Subscription Plans'}
            </h2>
            <p className="text-emerald-700">
              {isArabic ? 'اختر الباقة المناسبة لاحتياجاتك التعليمية' : 'Choose the plan that fits your learning needs'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {pricingPlans.map((plan, index) => (
              <div 
                key={index} 
                className={`relative bg-white rounded-xl shadow-md hover:shadow-lg transition overflow-hidden ${plan.popular ? 'border-2 border-gold-500' : ''}`}
              >
                {plan.popular && (
                  <div className="absolute top-0 left-0 right-0 bg-gold-500 text-emerald-900 py-1 text-center font-bold">
                    {isArabic ? 'الأكثر شعبية' : 'Most Popular'}
                  </div>
                )}
                <div className={`p-8 ${plan.popular ? 'pt-10' : ''}`}>
                  <h3 className="text-xl font-bold text-emerald-900 mb-4">{plan.title}</h3>
                  <div className="flex items-baseline mb-6">
                    <span className="text-4xl font-bold text-emerald-900">${plan.price}</span>
                    <span className="text-emerald-700 ml-1">/{plan.period}</span>
                  </div>
                  <ul className="space-y-3 mb-8">
                    {plan.features.map((feature, i) => (
                      <li key={i} className="flex items-center text-emerald-700">
                        <CheckCircle className="h-5 w-5 text-emerald-600 mr-2" />
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>
                  <button 
                    className={`w-full py-3 px-4 rounded-lg font-bold transition ${
                      plan.popular 
                        ? 'bg-gold-500 hover:bg-gold-600 text-emerald-900' 
                        : 'bg-emerald-600 hover:bg-emerald-700 text-white'
                    }`}
                  >
                    {plan.cta}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-16 bg-gradient-to-br from-emerald-900 to-green-800 text-white relative">
        <div className="absolute inset-0 opacity-5 bg-[url('https://i.imgur.com/XdJI2uU.png')] bg-repeat"></div>
        <div className="container mx-auto px-4 relative z-10">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold mb-2">
              {isArabic ? 'آراء طلابنا' : 'What Our Students Say'}
            </h2>
            <p className="text-gray-200">
              {isArabic ? 'تجارب حقيقية من طلاب أكاديمية رتل' : 'Real experiences from Rateel Academy students'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div key={index} className="bg-white/10 backdrop-blur rounded-xl p-6">
                <div className="text-gold-400 mb-4">
                  <svg className="h-8 w-8" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" />
                  </svg>
                </div>
                <p className="text-gray-200 mb-4">{testimonial.quote}</p>
                <div>
                  <p className="font-bold">{testimonial.name}</p>
                  <p className="text-gray-300">{testimonial.location}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4">
          <div className="bg-gradient-to-r from-emerald-900 to-green-800 rounded-2xl p-8 md:p-12 shadow-xl relative overflow-hidden">
            <div className="absolute inset-0 opacity-10 bg-[url('https://i.imgur.com/XdJI2uU.png')] bg-repeat"></div>
            <div className="relative z-10">
              <div className="text-center max-w-3xl mx-auto">
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                  {isArabic ? 'ابدأ رحلتك مع أكاديمية رتل اليوم' : 'Start Your Journey with Rateel Academy Today'}
                </h2>
                <p className="text-gray-200 mb-8">
                  {isArabic 
                    ? 'سجل الآن واحصل على جلسة تعريفية مجانية مع أحد معلمينا لتحديد المستوى المناسب لك'
                    : 'Register now and get a free introductory session with one of our teachers to determine your appropriate level'}
                </p>
                <div className="flex flex-col sm:flex-row justify-center space-y-4 sm:space-y-0 sm:space-x-4">
                  <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 font-bold py-3 px-8 rounded-lg transition">
                    {isArabic ? 'سجل الآن' : 'Register Now'}
                  </button>
                  <button className="bg-transparent border-2 border-white hover:bg-white hover:text-emerald-900 font-bold py-3 px-8 rounded-lg transition">
                    {isArabic ? 'تواصل معنا' : 'Contact Us'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-emerald-950 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <h3 className="text-xl font-bold mb-4">{isArabic ? 'أكاديمية رَتِّلِ' : 'Rateel Academy'}</h3>
              <p className="text-gray-300 mb-4">
                {isArabic 
                  ? 'منصة تعليمية متكاملة لتعلم القرآن الكريم واللغة العربية مع أفضل المعلمين من أي مكان'
                  : 'A comprehensive learning platform for Quran and Arabic with the best teachers from anywhere'}
              </p>
              <div className="flex space-x-4">
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z" />
                  </svg>
                </a>
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z" />
                  </svg>
                </a>
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
                  </svg>
                </a>
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z" />
                  </svg>
                </a>
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-bold mb-4">{isArabic ? 'روابط سريعة' : 'Quick Links'}</h3>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'الرئيسية' : 'Home'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'عن الأكاديمية' : 'About Academy'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'المسارات التعليمية' : 'Learning Paths'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'المعلمون' : 'Teachers'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'باقات الاشتراك' : 'Pricing Plans'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'تحميل التطبيق' : 'Download App'}</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-bold mb-4">{isArabic ? 'اتصل بنا' : 'Contact Us'}</h3>
              <ul className="space-y-2">
                <li className="flex items-start">
                  <svg className="h-6 w-6 text-gold-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  <span className="text-gray-300">+1 (555) 123-4567</span>
                </li>
                <li className="flex items-start">
                  <svg className="h-6 w-6 text-gold-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  <span className="text-gray-300">info@rateelacademy.com</span>
                </li>
                <li className="flex items-start">
                  <svg className="h-6 w-6 text-gold-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span className="text-gray-300">{isArabic ? 'مدينة دبي، الإمارات العربية المتحدة' : 'Dubai City, United Arab Emirates'}</span>
                </li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-bold mb-4">{isArabic ? 'النشرة الإخبارية' : 'Newsletter'}</h3>
              <p className="text-gray-300 mb-4">
                {isArabic 
                  ? 'اشترك في نشرتنا الإخبارية للحصول على آخر الأخبار والعروض الخاصة'
                  : 'Subscribe to our newsletter for the latest news and special offers'}
              </p>
              <form className="flex">
                <input 
                  type="email" 
                  placeholder={isArabic ? 'بريدك الإلكتروني' : 'Your email'} 
                  className="bg-emerald-900 text-white py-2 px-4 rounded-l-lg focus:outline-none flex-grow"
                />
                <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 py-2 px-4 rounded-r-lg transition">
                  {isArabic ? 'اشترك' : 'Subscribe'}
                </button>
              </form>
            </div>
          </div>
          
          <div className="mt-8 pt-8 border-t border-emerald-800 text-center text-gray-400">
            <p>© {new Date().getFullYear()} {isArabic ? 'أكاديمية رَتِّلِ - جميع الحقوق محفوظة' : 'Rateel Academy - All rights reserved'}</p>
          </div>
        </div>
      </footer>

      {/* Add custom style for the gold color that matches the Rateel app */}
      <style jsx global>{`
        :root {
          --color-gold-400: #FFD700;
          --color-gold-500: #DAA520;
          --color-gold-600: #B8860B;
        }
        
        .text-gold-400 {
          color: var(--color-gold-400);
        }
        
        .bg-gold-400 {
          background-color: var(--color-gold-400);
        }
        
        .text-gold-500 {
          color: var(--color-gold-500);
        }
        
        .bg-gold-500 {
          background-color: var(--color-gold-500);
        }
        
        .text-gold-600 {
          color: var(--color-gold-600);
        }
        
        .bg-gold-600 {
          background-color: var(--color-gold-600);
        }
        
        .border-gold-400 {
          border-color: var(--color-gold-400);
        }
        
        .border-gold-500 {
          border-color: var(--color-gold-500);
        }
        
        .border-gold-600 {
          border-color: var(--color-gold-600);
        }
        
        .from-gold-400 {
          --tw-gradient-from: var(--color-gold-400);
          --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(255, 215, 0, 0));
        }
        
        .from-gold-600 {
          --tw-gradient-from: var(--color-gold-600);
          --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(184, 134, 11, 0));
        }
        
        .to-gold-600 {
          --tw-gradient-to: var(--color-gold-600);
        }
        
        .to-gold-400 {
          --tw-gradient-to: var(--color-gold-400);
        }
        
        /* Add custom Arabic font */
        .font-arabic {
          font-family: 'Cairo', sans-serif;
        }
      `}</style>
    </div>
  );
}

```

<details><summary>risultato tool</summary>

```
Automated System Error: The generated artifact uses unsupported libraries: Certificate
Automated System Error: The generated artifact uses unsupported HTML elements: form
```
</details>



Let me create a revised version of the website that meets the requirements without using unsupported elements:

**Artifact: Rateel Academy Website** (`application/vnd.ant.react`, create)

```jsx
import React, { useState } from 'react';
import { ChevronRight, ChevronLeft, CheckCircle, Award, Users, Book, Mic, Globe, Star, Menu, X } from 'lucide-react';

export default function RateelAcademy() {
  const [language, setLanguage] = useState('english'); // 'english' or 'arabic'
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  const toggleLanguage = () => {
    setLanguage(language === 'english' ? 'arabic' : 'english');
  };
  
  const toggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };
  
  const isArabic = language === 'arabic';
  
  const learningPaths = [
    {
      title: isArabic ? 'تعلم القرآن الكريم' : 'Quran Learning',
      description: isArabic ? 'دروس في التلاوة والتجويد والحفظ مع معلمين متخصصين' : 'Lessons in recitation, tajweed and memorization with specialized teachers',
      icon: <Book className="h-8 w-8" />,
      features: isArabic ? ['التجويد', 'الحفظ', 'التفسير'] : ['Tajweed', 'Memorization', 'Tafsir']
    },
    {
      title: isArabic ? 'تعلم اللغة العربية' : 'Arabic Language',
      description: isArabic ? 'تعلم اللغة العربية من المستوى المبتدئ إلى المتقدم' : 'Learn Arabic from beginner to advanced level',
      icon: <Globe className="h-8 w-8" />,
      features: isArabic ? ['النحو', 'الصرف', 'المحادثة'] : ['Grammar', 'Vocabulary', 'Conversation'] 
    },
    {
      title: isArabic ? 'الإجازات والشهادات' : 'Certificates & Ijazah',
      description: isArabic ? 'احصل على شهادات معتمدة وإجازات في القراءات' : 'Get certified with recognized certificates and Ijazah in Qira\'at',
      icon: <Award className="h-8 w-8" />,
      features: isArabic ? ['إجازة حفص', 'إجازات القراءات', 'شهادات معتمدة'] : ['Hafs Ijazah', 'Qira\'at Ijazahs', 'Certified Diplomas']
    },
    {
      title: isArabic ? 'التدريب الصوتي' : 'Voice Training',
      description: isArabic ? 'تدريب صوتي متخصص لتحسين تلاوتك ومخارج الحروف' : 'Specialized voice training to improve your recitation and pronunciation',
      icon: <Mic className="h-8 w-8" />,
      features: isArabic ? ['مخارج الحروف', 'الصفات', 'تقويم اللسان'] : ['Pronunciation', 'Characteristics', 'Tongue Training']
    }
  ];
  
  const teachers = [
    {
      name: isArabic ? 'الشيخ عبدالله محمد' : 'Sheikh Abdullah Muhammad',
      role: isArabic ? 'أستاذ القراءات والتجويد' : 'Professor of Qira\'at & Tajweed',
      image: '/api/placeholder/400/400',
      rating: 4.9
    },
    {
      name: isArabic ? 'الأستاذة نور أحمد' : 'Ustadha Noor Ahmed',
      role: isArabic ? 'معلمة اللغة العربية والتفسير' : 'Arabic Language & Tafsir Teacher',
      image: '/api/placeholder/400/400',
      rating: 4.8
    },
    {
      name: isArabic ? 'الشيخ محمد علي' : 'Sheikh Muhammad Ali',
      role: isArabic ? 'حافظ ومجاز بالقراءات العشر' : 'Hafiz & Certified in 10 Qira\'at',
      image: '/api/placeholder/400/400',
      rating: 4.9
    }
  ];
  
  const pricingPlans = [
    {
      title: isArabic ? 'الباقة الأساسية' : 'Essential Plan',
      price: isArabic ? '٣٩' : '39',
      period: isArabic ? 'شهرياً' : 'per month',
      features: isArabic 
        ? ['درسان أسبوعياً', 'تطبيق رتل مجاناً', 'دعم فني', 'تقارير تقدم شهرية'] 
        : ['2 Classes Weekly', 'Free Rateel App', 'Technical Support', 'Monthly Progress Reports'],
      cta: isArabic ? 'اشترك الآن' : 'Subscribe Now',
      popular: false
    },
    {
      title: isArabic ? 'الباقة المميزة' : 'Premium Plan',
      price: isArabic ? '٦٩' : '69',
      period: isArabic ? 'شهرياً' : 'per month',
      features: isArabic 
        ? ['٤ دروس أسبوعياً', 'تطبيق رتل مجاناً', 'دعم فني على مدار الساعة', 'تقارير تقدم أسبوعية', 'جلسات فردية'] 
        : ['4 Classes Weekly', 'Free Rateel App', '24/7 Technical Support', 'Weekly Progress Reports', 'One-on-One Sessions'],
      cta: isArabic ? 'اشترك الآن' : 'Subscribe Now',
      popular: true
    },
    {
      title: isArabic ? 'باقة العائلة' : 'Family Plan',
      price: isArabic ? '٩٩' : '99',
      period: isArabic ? 'شهرياً' : 'per month',
      features: isArabic 
        ? ['حتى ٣ أفراد', '٦ دروس أسبوعياً', 'تطبيق رتل مجاناً', 'دعم فني على مدار الساعة', 'تقارير تقدم أسبوعية', 'جلسات فردية'] 
        : ['Up to 3 Family Members', '6 Classes Weekly', 'Free Rateel App', '24/7 Technical Support', 'Weekly Progress Reports', 'One-on-One Sessions'],
      cta: isArabic ? 'اشترك الآن' : 'Subscribe Now',
      popular: false
    }
  ];
  
  const testimonials = [
    {
      quote: isArabic 
        ? 'تجربة تعليمية رائعة! تحسنت تلاوتي بشكل كبير مع المعلمين المتميزين في أكاديمية رتل.' 
        : 'Amazing learning experience! My recitation has improved significantly with the excellent teachers at Rateel Academy.',
      name: isArabic ? 'أحمد محمود' : 'Ahmed Mahmoud',
      location: isArabic ? 'مصر' : 'Egypt'
    },
    {
      quote: isArabic 
        ? 'كوني أماً لثلاثة أطفال، وجدت في باقة العائلة الحل الأمثل لتعليم أطفالي القرآن واللغة العربية من المنزل.' 
        : 'As a mother of three, the family plan was the perfect solution for teaching my children Quran and Arabic from home.',
      name: isArabic ? 'فاطمة علي' : 'Fatima Ali',
      location: isArabic ? 'الإمارات' : 'UAE'
    },
    {
      quote: isArabic 
        ? 'تطبيق رتل المرفق مع الدروس الحية يساعدني على المراجعة والتدرب في أي وقت.' 
        : 'The Rateel app that comes with the live lessons helps me review and practice anytime.',
      name: isArabic ? 'محمد عبدالله' : 'Mohammed Abdullah',
      location: isArabic ? 'المملكة المتحدة' : 'United Kingdom'
    }
  ];

  return (
    <div dir={isArabic ? 'rtl' : 'ltr'} className={`min-h-screen font-sans ${isArabic ? 'font-arabic' : ''}`}>
      {/* Header */}
      <header className="bg-gradient-to-r from-emerald-900 to-green-800 text-white shadow-lg">
        <div className="container mx-auto px-4 py-3">
          <div className="flex justify-between items-center">
            <div className="flex items-center">
              <div className="text-2xl font-bold mr-2">
                {isArabic ? 'أكاديمية رَتِّلِ' : 'Rateel Academy'}
              </div>
            </div>
            
            {/* Desktop Menu */}
            <nav className="hidden md:flex items-center space-x-6">
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'الرئيسية' : 'Home'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'المسارات' : 'Paths'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'المعلمون' : 'Teachers'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'الباقات' : 'Pricing'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'التطبيق' : 'App'}</a>
              <a href="#" className="hover:text-gold-400 transition">{isArabic ? 'تواصل معنا' : 'Contact'}</a>
              <button 
                onClick={toggleLanguage}
                className="bg-transparent border border-gold-400 text-gold-400 px-4 py-2 rounded-lg hover:bg-gold-400 hover:text-emerald-900 transition"
              >
                {isArabic ? 'English' : 'العربية'}
              </button>
            </nav>
            
            {/* Mobile Menu Button */}
            <div className="md:hidden flex items-center">
              <button onClick={toggleLanguage} className="mr-4 text-gold-400">
                {isArabic ? 'EN' : 'AR'}
              </button>
              <button onClick={toggleMobileMenu} className="text-white">
                {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
              </button>
            </div>
          </div>
          
          {/* Mobile Menu */}
          {mobileMenuOpen && (
            <nav className="md:hidden pt-4 pb-2 space-y-2">
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'الرئيسية' : 'Home'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'المسارات' : 'Paths'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'المعلمون' : 'Teachers'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'الباقات' : 'Pricing'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'التطبيق' : 'App'}</a>
              <a href="#" className="block py-2 hover:text-gold-400 transition">{isArabic ? 'تواصل معنا' : 'Contact'}</a>
            </nav>
          )}
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-emerald-900 via-green-800 to-emerald-950 text-white py-16">
        <div className="absolute inset-0 opacity-10 bg-pattern"></div>
        <div className="container mx-auto px-4 relative z-10">
          <div className="flex flex-col md:flex-row items-center">
            <div className="md:w-1/2 mb-10 md:mb-0">
              <h1 className="text-4xl md:text-5xl font-bold mb-4">
                {isArabic ? 'تعلم القرآن واللغة العربية مع أفضل المعلمين' : 'Learn Quran & Arabic with Expert Teachers'}
              </h1>
              <p className="text-lg mb-8 text-gray-200">
                {isArabic 
                  ? 'دروس مباشرة، تطبيق تفاعلي، وشهادات معتمدة - رحلة تعليمية متكاملة من منزلك مع أكاديمية رتل'
                  : 'Live classes, interactive app, and certified credentials - a complete learning journey from your home with Rateel Academy'}
              </p>
              <div className="flex flex-wrap gap-4">
                <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 font-bold py-3 px-6 rounded-lg transition">
                  {isArabic ? 'ابدأ الآن' : 'Get Started'}
                </button>
                <button className="bg-transparent border-2 border-white hover:bg-white hover:text-emerald-900 font-bold py-3 px-6 rounded-lg transition">
                  {isArabic ? 'تجربة مجانية' : 'Free Trial'}
                </button>
              </div>
            </div>
            <div className="md:w-1/2 flex justify-center">
              <div className="relative">
                <div className="absolute -inset-0.5 bg-gradient-to-r from-gold-400 to-gold-600 rounded-2xl blur opacity-30"></div>
                <div className="relative bg-emerald-950/70 p-2 rounded-2xl overflow-hidden">
                  <img 
                    src="/api/placeholder/600/400" 
                    alt="Quran Learning" 
                    className="rounded-xl w-full max-w-md"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Learning Paths */}
      <section className="py-16 bg-emerald-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-emerald-900 mb-2">
              {isArabic ? 'مسارات التعلم' : 'Learning Paths'}
            </h2>
            <p className="text-emerald-700">
              {isArabic ? 'اختر المسار المناسب لك وابدأ رحلتك التعليمية' : 'Choose your perfect path and start your learning journey'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {learningPaths.map((path, index) => (
              <div key={index} className="bg-white rounded-xl shadow-md hover:shadow-lg transition p-6 border-t-4 border-gold-500">
                <div className="text-gold-500 mb-4">
                  {path.icon}
                </div>
                <h3 className="text-xl font-bold text-emerald-900 mb-2">{path.title}</h3>
                <p className="text-emerald-700 mb-4">{path.description}</p>
                <ul className="space-y-2">
                  {path.features.map((feature, i) => (
                    <li key={i} className="flex items-center text-emerald-700">
                      <CheckCircle className="h-4 w-4 text-emerald-600 mr-2" />
                      <span>{feature}</span>
                    </li>
                  ))}
                </ul>
                <button className="mt-6 w-full py-2 px-4 bg-emerald-100 text-emerald-700 rounded-lg hover:bg-emerald-200 transition">
                  {isArabic ? 'اكتشف المزيد' : 'Learn More'}
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* App Showcase */}
      <section className="py-16 bg-gradient-to-br from-emerald-900 to-green-800 text-white relative overflow-hidden">
        <div className="absolute inset-0 opacity-5 bg-pattern"></div>
        <div className="container mx-auto px-4 relative z-10">
          <div className="flex flex-col md:flex-row items-center">
            <div className="md:w-1/2 mb-10 md:mb-0">
              <h2 className="text-3xl font-bold mb-4">
                {isArabic ? 'تطبيق رَتِّلِ - مساعدك الشخصي في رحلة التعلم' : 'Rateel App - Your Personal Learning Assistant'}
              </h2>
              <p className="text-lg mb-6">
                {isArabic 
                  ? 'استكمل رحلتك التعليمية مع تطبيق رتل المتاح لجميع المشتركين. تدرب على التجويد، تتبع تقدمك، وحسن أدائك بين دروسك المباشرة.'
                  : 'Complete your learning journey with the Rateel app included for all subscribers. Practice tajweed, track your progress, and improve between your live classes.'}
              </p>
              <div className="space-y-4">
                <div className="flex items-start">
                  <div className="bg-gold-500 p-2 rounded-full text-emerald-900 mr-3">
                    <Award className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold">{isArabic ? 'تقييم صوتي متقدم' : 'Advanced Voice Evaluation'}</h3>
                    <p className="text-gray-200">{isArabic ? 'تقييم فوري لتلاوتك وقراءتك' : 'Instant feedback on your recitation'}</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <div className="bg-gold-500 p-2 rounded-full text-emerald-900 mr-3">
                    <Book className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold">{isArabic ? 'دروس تفاعلية' : 'Interactive Lessons'}</h3>
                    <p className="text-gray-200">{isArabic ? 'مسارات تعليمية مخصصة لكل مستوى' : 'Customized learning paths for every level'}</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <div className="bg-gold-500 p-2 rounded-full text-emerald-900 mr-3">
                    <Users className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold">{isArabic ? 'متوافق مع دروسك المباشرة' : 'Synchronized with Live Classes'}</h3>
                    <p className="text-gray-200">{isArabic ? 'اطلع معلمك على تقدمك في التطبيق' : 'Your teacher can review your app progress'}</p>
                  </div>
                </div>
              </div>
              <div className="mt-8">
                <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 font-bold py-3 px-6 rounded-lg transition">
                  {isArabic ? 'تحميل التطبيق' : 'Download App'}
                </button>
              </div>
            </div>
            <div className="md:w-1/2 flex justify-center">
              <div className="relative w-72">
                <div className="absolute -inset-1 bg-gradient-to-r from-gold-400 to-gold-600 rounded-[32px] blur opacity-30"></div>
                <div className="relative">
                  <img 
                    src="/api/placeholder/360/600" 
                    alt="Rateel App" 
                    className="w-full relative z-10"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Teachers */}
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-emerald-900 mb-2">
              {isArabic ? 'نخبة من المعلمين' : 'Our Expert Teachers'}
            </h2>
            <p className="text-emerald-700">
              {isArabic ? 'تعلم مع أفضل المعلمين المؤهلين والمجازين' : 'Learn with the best qualified and certified teachers'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {teachers.map((teacher, index) => (
              <div key={index} className="bg-white rounded-xl shadow-md hover:shadow-lg transition overflow-hidden">
                <div className="h-56 overflow-hidden relative">
                  <img 
                    src={teacher.image} 
                    alt={teacher.name} 
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4">
                    <div className="flex items-center">
                      <div className="bg-gold-500 text-emerald-900 rounded-full py-1 px-3 text-sm font-bold flex items-center">
                        <Star className="h-3 w-3 mr-1" fill="currentColor" />
                        {teacher.rating}
                      </div>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  <h3 className="text-xl font-bold text-emerald-900 mb-1">{teacher.name}</h3>
                  <p className="text-emerald-700 mb-4">{teacher.role}</p>
                  <button className="w-full py-2 px-4 border border-emerald-600 text-emerald-600 rounded-lg hover:bg-emerald-50 transition">
                    {isArabic ? 'عرض الملف الشخصي' : 'View Profile'}
                  </button>
                </div>
              </div>
            ))}
          </div>
          
          <div className="mt-12 text-center">
            <button className="bg-emerald-100 hover:bg-emerald-200 text-emerald-700 font-bold py-3 px-6 rounded-lg transition inline-flex items-center">
              {isArabic ? 'عرض كافة المعلمين' : 'View All Teachers'} 
              {isArabic ? <ChevronLeft className="h-5 w-5 ml-1" /> : <ChevronRight className="h-5 w-5 ml-1" />}
            </button>
          </div>
        </div>
      </section>

      {/* Pricing Plans */}
      <section className="py-16 bg-emerald-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-emerald-900 mb-2">
              {isArabic ? 'باقات الاشتراك' : 'Subscription Plans'}
            </h2>
            <p className="text-emerald-700">
              {isArabic ? 'اختر الباقة المناسبة لاحتياجاتك التعليمية' : 'Choose the plan that fits your learning needs'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {pricingPlans.map((plan, index) => (
              <div 
                key={index} 
                className={`relative bg-white rounded-xl shadow-md hover:shadow-lg transition overflow-hidden ${plan.popular ? 'border-2 border-gold-500' : ''}`}
              >
                {plan.popular && (
                  <div className="absolute top-0 left-0 right-0 bg-gold-500 text-emerald-900 py-1 text-center font-bold">
                    {isArabic ? 'الأكثر شعبية' : 'Most Popular'}
                  </div>
                )}
                <div className={`p-8 ${plan.popular ? 'pt-10' : ''}`}>
                  <h3 className="text-xl font-bold text-emerald-900 mb-4">{plan.title}</h3>
                  <div className="flex items-baseline mb-6">
                    <span className="text-4xl font-bold text-emerald-900">${plan.price}</span>
                    <span className="text-emerald-700 ml-1">/{plan.period}</span>
                  </div>
                  <ul className="space-y-3 mb-8">
                    {plan.features.map((feature, i) => (
                      <li key={i} className="flex items-center text-emerald-700">
                        <CheckCircle className="h-5 w-5 text-emerald-600 mr-2" />
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>
                  <button 
                    className={`w-full py-3 px-4 rounded-lg font-bold transition ${
                      plan.popular 
                        ? 'bg-gold-500 hover:bg-gold-600 text-emerald-900' 
                        : 'bg-emerald-600 hover:bg-emerald-700 text-white'
                    }`}
                  >
                    {plan.cta}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-16 bg-gradient-to-br from-emerald-900 to-green-800 text-white relative">
        <div className="absolute inset-0 opacity-5 bg-pattern"></div>
        <div className="container mx-auto px-4 relative z-10">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold mb-2">
              {isArabic ? 'آراء طلابنا' : 'What Our Students Say'}
            </h2>
            <p className="text-gray-200">
              {isArabic ? 'تجارب حقيقية من طلاب أكاديمية رتل' : 'Real experiences from Rateel Academy students'}
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div key={index} className="bg-white/10 backdrop-blur rounded-xl p-6">
                <div className="text-gold-400 mb-4">
                  <svg className="h-8 w-8" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" />
                  </svg>
                </div>
                <p className="text-gray-200 mb-4">{testimonial.quote}</p>
                <div>
                  <p className="font-bold">{testimonial.name}</p>
                  <p className="text-gray-300">{testimonial.location}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4">
          <div className="bg-gradient-to-r from-emerald-900 to-green-800 rounded-2xl p-8 md:p-12 shadow-xl relative overflow-hidden">
            <div className="absolute inset-0 opacity-10 bg-pattern"></div>
            <div className="relative z-10">
              <div className="text-center max-w-3xl mx-auto">
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                  {isArabic ? 'ابدأ رحلتك مع أكاديمية رتل اليوم' : 'Start Your Journey with Rateel Academy Today'}
                </h2>
                <p className="text-gray-200 mb-8">
                  {isArabic 
                    ? 'سجل الآن واحصل على جلسة تعريفية مجانية مع أحد معلمينا لتحديد المستوى المناسب لك'
                    : 'Register now and get a free introductory session with one of our teachers to determine your appropriate level'}
                </p>
                <div className="flex flex-col sm:flex-row justify-center space-y-4 sm:space-y-0 sm:space-x-4">
                  <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 font-bold py-3 px-8 rounded-lg transition">
                    {isArabic ? 'سجل الآن' : 'Register Now'}
                  </button>
                  <button className="bg-transparent border-2 border-white hover:bg-white hover:text-emerald-900 font-bold py-3 px-8 rounded-lg transition">
                    {isArabic ? 'تواصل معنا' : 'Contact Us'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-emerald-950 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <h3 className="text-xl font-bold mb-4">{isArabic ? 'أكاديمية رَتِّلِ' : 'Rateel Academy'}</h3>
              <p className="text-gray-300 mb-4">
                {isArabic 
                  ? 'منصة تعليمية متكاملة لتعلم القرآن الكريم واللغة العربية مع أفضل المعلمين من أي مكان'
                  : 'A comprehensive learning platform for Quran and Arabic with the best teachers from anywhere'}
              </p>
              <div className="flex space-x-4">
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z" />
                  </svg>
                </a>
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z" />
                  </svg>
                </a>
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
                  </svg>
                </a>
                <a href="#" className="text-gray-300 hover:text-gold-400 transition">
                  <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z" />
                  </svg>
                </a>
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-bold mb-4">{isArabic ? 'روابط سريعة' : 'Quick Links'}</h3>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'الرئيسية' : 'Home'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'عن الأكاديمية' : 'About Academy'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'المسارات التعليمية' : 'Learning Paths'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'المعلمون' : 'Teachers'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'باقات الاشتراك' : 'Pricing Plans'}</a></li>
                <li><a href="#" className="text-gray-300 hover:text-gold-400 transition">{isArabic ? 'تحميل التطبيق' : 'Download App'}</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-bold mb-4">{isArabic ? 'اتصل بنا' : 'Contact Us'}</h3>
              <ul className="space-y-2">
                <li className="flex items-start">
                  <svg className="h-6 w-6 text-gold-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  <span className="text-gray-300">+1 (555) 123-4567</span>
                </li>
                <li className="flex items-start">
                  <svg className="h-6 w-6 text-gold-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  <span className="text-gray-300">info@rateelacademy.com</span>
                </li>
                <li className="flex items-start">
                  <svg className="h-6 w-6 text-gold-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span className="text-gray-300">{isArabic ? 'مدينة دبي، الإمارات العربية المتحدة' : 'Dubai City, United Arab Emirates'}</span>
                </li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-lg font-bold mb-4">{isArabic ? 'النشرة الإخبارية' : 'Newsletter'}</h3>
              <p className="text-gray-300 mb-4">
                {isArabic 
                  ? 'اشترك في نشرتنا الإخبارية للحصول على آخر الأخبار والعروض الخاصة'
                  : 'Subscribe to our newsletter for the latest news and special offers'}
              </p>
              <div className="flex">
                <div className="bg-emerald-900 text-white py-2 px-4 rounded-l-lg flex-grow">
                  {isArabic ? 'بريدك الإلكتروني' : 'Your email'}
                </div>
                <button className="bg-gold-500 hover:bg-gold-600 text-emerald-900 py-2 px-4 rounded-r-lg transition">
                  {isArabic ? 'اشترك' : 'Subscribe'}
                </button>
              </div>
            </div>
          </div>
          
          <div className="mt-8 pt-8 border-t border-emerald-800 text-center text-gray-400">
            <p>© {new Date().getFullYear()} {isArabic ? 'أكاديمية رَتِّلِ - جميع الحقوق محفوظة' : 'Rateel Academy - All rights reserved'}</p>
          </div>
        </div>
      </footer>

      {/* Add custom style for the gold color that matches the Rateel app */}
      <style jsx global>{`
        :root {
          --color-gold-400: #FFD700;
          --color-gold-500: #DAA520;
          --color-gold-600: #B8860B;
        }
        
        .text-gold-400 {
          color: var(--color-gold-400);
        }
        
        .bg-gold-400 {
          background-color: var(--color-gold-400);
        }
        
        .text-gold-500 {
          color: var(--color-gold-500);
        }
        
        .bg-gold-500 {
          background-color: var(--color-gold-500);
        }
        
        .text-gold-600 {
          color: var(--color-gold-600);
        }
        
        .bg-gold-600 {
          background-color: var(--color-gold-600);
        }
        
        .border-gold-400 {
          border-color: var(--color-gold-400);
        }
        
        .border-gold-500 {
          border-color: var(--color-gold-500);
        }
        
        .border-gold-600 {
          border-color: var(--color-gold-600);
        }
        
        .from-gold-400 {
          --tw-gradient-from: var(--color-gold-400);
          --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(255, 215, 0, 0));
        }
        
        .from-gold-600 {
          --tw-gradient-from: var(--color-gold-600);
          --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(184, 134, 11, 0));
        }
        
        .to-gold-600 {
          --tw-gradient-to: var(--color-gold-600);
        }
        
        .to-gold-400 {
          --tw-gradient-to: var(--color-gold-400);
        }
        
        /* Add custom Arabic font */
        .font-arabic {
          font-family: 'Cairo', sans-serif;
        }
        
        /* Add Islamic pattern background */
        .bg-pattern {
          background-image: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.1' fill-rule='evenodd'/%3E%3C/svg%3E");
          background-repeat: repeat;
        }
      `}</style>
    </div>
  );
}

```

<details><summary>risultato tool</summary>

```
OK
```
</details>

## Yassin (2025-05-18T18:55)

Continue

## Claude (2025-05-18T18:57)

# Expanding the Rateel Academy Website

Let me continue developing the Rateel Academy website by creating an interactive course curriculum page that showcases the detailed learning paths and course structures. This will help potential students understand what they'll learn through the academy.

**Artifact: Rateel Academy Course Curriculum** (`application/vnd.ant.react`, create)

```jsx
import React, { useState } from 'react';
import { ChevronRight, ChevronLeft, ChevronDown, CheckCircle, Book, Mic, Award, Play, Clock, Star, Users, Video } from 'lucide-react';

export default function CoursesCurriculum() {
  const [language, setLanguage] = useState('english'); // 'english' or 'arabic'
  const [expandedCourse, setExpandedCourse] = useState(0);
  const [expandedModule, setExpandedModule] = useState(null);
  
  const toggleLanguage = () => {
    setLanguage(language === 'english' ? 'arabic' : 'english');
  };
  
  const isArabic = language === 'arabic';
  
  // Function to toggle expanded course
  const toggleCourse = (index) => {
    setExpandedCourse(expandedCourse === index ? null : index);
    setExpandedModule(null); // Reset expanded module when toggling course
  };
  
  // Function to toggle expanded module
  const toggleModule = (courseIndex, moduleIndex) => {
    setExpandedModule(expandedModule === `${courseIndex}-${moduleIndex}` ? null : `${courseIndex}-${moduleIndex}`);
  };

  // Course data
  const courses = [
    {
      id: 1,
      title: isArabic ? 'تجويد القرآن للمبتدئين' : 'Quran Tajweed for Beginners',
      description: isArabic 
        ? 'مسار شامل لتعلم أساسيات التجويد وقواعد النطق الصحيح لحروف القرآن الكريم'
        : 'A comprehensive path to learn the fundamentals of Tajweed and proper pronunciation rules for Quranic letters',
      duration: isArabic ? '٣ أشهر' : '3 months',
      lessons: isArabic ? '٢٤ درساً' : '24 lessons',
      level: isArabic ? 'مبتدئ' : 'Beginner',
      rating: 4.9,
      reviews: isArabic ? '٤٥٠ تقييم' : '450 reviews',
      students: isArabic ? '١٢٠٠+' : '1,200+',
      image: '/api/placeholder/800/400',
      instructors: [
        { name: isArabic ? 'الشيخ عبدالله محمد' : 'Sheikh Abdullah Muhammad', image: '/api/placeholder/100/100' },
        { name: isArabic ? 'الشيخ أحمد علي' : 'Sheikh Ahmed Ali', image: '/api/placeholder/100/100' }
      ],
      modules: [
        {
          title: isArabic ? 'مقدمة في علم التجويد' : 'Introduction to Tajweed',
          lessons: [
            { title: isArabic ? 'أهمية التجويد وفضله' : 'Importance of Tajweed', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'مصطلحات علم التجويد' : 'Tajweed Terminology', duration: isArabic ? '٥٠ دقيقة' : '50 minutes', type: 'video' },
            { title: isArabic ? 'الاستعاذة والبسملة' : 'Isti\'adha and Basmala', duration: isArabic ? '٣٠ دقيقة' : '30 minutes', type: 'interactive' },
            { title: isArabic ? 'تقييم المستوى الأولي' : 'Initial Assessment', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'assessment' }
          ]
        },
        {
          title: isArabic ? 'مخارج الحروف' : 'Letter Articulation Points',
          lessons: [
            { title: isArabic ? 'مخارج الحروف الحلقية' : 'Throat Letters Articulation', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'مخارج الحروف اللسانية' : 'Tongue Letters Articulation', duration: isArabic ? '٥٥ دقيقة' : '55 minutes', type: 'video' },
            { title: isArabic ? 'مخارج الحروف الشفوية' : 'Lip Letters Articulation', duration: isArabic ? '٤٠ دقيقة' : '40 minutes', type: 'video' },
            { title: isArabic ? 'تدريبات عملية على المخارج' : 'Practical Exercises on Articulation', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'practice' },
            { title: isArabic ? 'تقييم المخارج' : 'Articulation Assessment', duration: isArabic ? '٣٠ دقيقة' : '30 minutes', type: 'assessment' }
          ]
        },
        {
          title: isArabic ? 'صفات الحروف' : 'Letter Characteristics',
          lessons: [
            { title: isArabic ? 'الصفات المتضادة' : 'Contrasting Characteristics', duration: isArabic ? '٥٠ دقيقة' : '50 minutes', type: 'video' },
            { title: isArabic ? 'الصفات غير المتضادة' : 'Non-contrasting Characteristics', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'تدريبات على صفات الحروف' : 'Exercises on Letter Characteristics', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'practice' }
          ]
        },
        {
          title: isArabic ? 'أحكام النون الساكنة والتنوين' : 'Rules of Noon Sakinah and Tanween',
          lessons: [
            { title: isArabic ? 'الإظهار' : 'Al-Izhar (Clear Pronunciation)', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'الإدغام' : 'Al-Idgham (Merging)', duration: isArabic ? '٥٠ دقيقة' : '50 minutes', type: 'video' },
            { title: isArabic ? 'الإقلاب' : 'Al-Iqlab (Conversion)', duration: isArabic ? '٤٠ دقيقة' : '40 minutes', type: 'video' },
            { title: isArabic ? 'الإخفاء' : 'Al-Ikhfa (Hiding)', duration: isArabic ? '٥٥ دقيقة' : '55 minutes', type: 'video' },
            { title: isArabic ? 'تدريبات شاملة' : 'Comprehensive Exercises', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'practice' },
            { title: isArabic ? 'تقييم نهائي للمستوى الأول' : 'Final Assessment Level 1', duration: isArabic ? '٩٠ دقيقة' : '90 minutes', type: 'assessment' }
          ]
        }
      ]
    },
    {
      id: 2,
      title: isArabic ? 'اللغة العربية للمبتدئين' : 'Arabic Language for Beginners',
      description: isArabic 
        ? 'دورة متكاملة لتعلم أساسيات اللغة العربية من الصفر، مناسبة للمبتدئين الذين يرغبون في تعلم القراءة والكتابة والمحادثة'
        : 'A comprehensive course to learn Arabic basics from scratch, perfect for beginners wanting to learn reading, writing, and conversation',
      duration: isArabic ? '٤ أشهر' : '4 months',
      lessons: isArabic ? '٣٢ درساً' : '32 lessons',
      level: isArabic ? 'مبتدئ' : 'Beginner',
      rating: 4.8,
      reviews: isArabic ? '٣٢٠ تقييم' : '320 reviews',
      students: isArabic ? '٩٥٠+' : '950+',
      image: '/api/placeholder/800/400',
      instructors: [
        { name: isArabic ? 'الأستاذة نور أحمد' : 'Ustadha Noor Ahmed', image: '/api/placeholder/100/100' },
        { name: isArabic ? 'الأستاذ محمد حسن' : 'Ustadh Mohammed Hassan', image: '/api/placeholder/100/100' }
      ],
      modules: [
        {
          title: isArabic ? 'الحروف العربية ونطقها' : 'Arabic Alphabet and Pronunciation',
          lessons: [
            { title: isArabic ? 'تعلم الحروف العربية' : 'Learning the Arabic Alphabet', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'video' },
            { title: isArabic ? 'أشكال الحروف المختلفة' : 'Different Letter Forms', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'تدريبات الكتابة والنطق' : 'Writing and Pronunciation Exercises', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'practice' },
            { title: isArabic ? 'تقييم الحروف' : 'Alphabet Assessment', duration: isArabic ? '٣٠ دقيقة' : '30 minutes', type: 'assessment' }
          ]
        },
        {
          title: isArabic ? 'الحركات والتشكيل' : 'Vowels and Diacritics',
          lessons: [
            { title: isArabic ? 'الفتحة والضمة والكسرة' : 'Fatha, Damma, and Kasra', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'السكون والشدة' : 'Sukoon and Shadda', duration: isArabic ? '٤٠ دقيقة' : '40 minutes', type: 'video' },
            { title: isArabic ? 'التنوين' : 'Tanween', duration: isArabic ? '٤٠ دقيقة' : '40 minutes', type: 'video' },
            { title: isArabic ? 'تدريبات القراءة' : 'Reading Exercises', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'practice' }
          ]
        },
        {
          title: isArabic ? 'الكلمات والجمل البسيطة' : 'Simple Words and Sentences',
          lessons: [
            { title: isArabic ? 'المفردات الأساسية' : 'Essential Vocabulary', duration: isArabic ? '٥٠ دقيقة' : '50 minutes', type: 'video' },
            { title: isArabic ? 'تكوين الجمل البسيطة' : 'Forming Simple Sentences', duration: isArabic ? '٥٥ دقيقة' : '55 minutes', type: 'video' },
            { title: isArabic ? 'التحية والتعارف' : 'Greetings and Introductions', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'interactive' },
            { title: isArabic ? 'تدريبات المحادثة' : 'Conversation Practice', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'practice' },
            { title: isArabic ? 'تقييم المحادثة' : 'Conversation Assessment', duration: isArabic ? '٣٠ دقيقة' : '30 minutes', type: 'assessment' }
          ]
        }
      ]
    },
    {
      id: 3,
      title: isArabic ? 'حفظ القرآن: جزء عم' : 'Quran Memorization: Juz Amma',
      description: isArabic 
        ? 'برنامج متخصص لحفظ جزء عم (الجزء الثلاثين) من القرآن الكريم مع التركيز على الحفظ المتقن والمراجعة المنتظمة'
        : 'Specialized program for memorizing Juz Amma (30th part) of the Quran with focus on perfect memorization and regular revision',
      duration: isArabic ? '٦ أشهر' : '6 months',
      lessons: isArabic ? '٣٦ درساً' : '36 lessons',
      level: isArabic ? 'جميع المستويات' : 'All Levels',
      rating: 4.9,
      reviews: isArabic ? '٥١٠ تقييم' : '510 reviews',
      students: isArabic ? '١٥٠٠+' : '1,500+',
      image: '/api/placeholder/800/400',
      instructors: [
        { name: isArabic ? 'الشيخ محمد علي' : 'Sheikh Muhammad Ali', image: '/api/placeholder/100/100' },
        { name: isArabic ? 'الشيخة سارة عبدالله' : 'Sheikha Sara Abdullah', image: '/api/placeholder/100/100' }
      ],
      modules: [
        {
          title: isArabic ? 'أساسيات الحفظ' : 'Fundamentals of Memorization',
          lessons: [
            { title: isArabic ? 'أفضل طرق الحفظ' : 'Best Memorization Methods', duration: isArabic ? '٥٠ دقيقة' : '50 minutes', type: 'video' },
            { title: isArabic ? 'تقنيات المراجعة الفعالة' : 'Effective Revision Techniques', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'video' },
            { title: isArabic ? 'التسميع والمراجعة' : 'Recitation and Revision', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' }
          ]
        },
        {
          title: isArabic ? 'حفظ السور القصيرة (من الناس إلى الضحى)' : 'Memorizing Short Surahs (An-Nas to Ad-Duha)',
          lessons: [
            { title: isArabic ? 'حفظ سورة الناس إلى سورة المسد' : 'Memorizing An-Nas to Al-Masad', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'حفظ سورة النصر إلى سورة الكافرون' : 'Memorizing An-Nasr to Al-Kafirun', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'حفظ سورة الكوثر إلى سورة الماعون' : 'Memorizing Al-Kawthar to Al-Ma\'un', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'تقييم الحفظ والمراجعة' : 'Memorization Assessment', duration: isArabic ? '٤٥ دقيقة' : '45 minutes', type: 'assessment' }
          ]
        },
        {
          title: isArabic ? 'حفظ سور الجزء الثاني (من الضحى إلى النبأ)' : 'Memorizing Second Part (Ad-Duha to An-Naba)',
          lessons: [
            { title: isArabic ? 'حفظ سورة الضحى إلى سورة الشرح' : 'Memorizing Ad-Duha to Ash-Sharh', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'حفظ سورة التين إلى سورة العلق' : 'Memorizing At-Tin to Al-Alaq', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'حفظ سورة القدر إلى سورة البينة' : 'Memorizing Al-Qadr to Al-Bayyinah', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'حفظ سورة الزلزلة إلى سورة القارعة' : 'Memorizing Az-Zalzalah to Al-Qariah', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'حفظ سورة التكاثر إلى سورة الهمزة' : 'Memorizing At-Takathur to Al-Humazah', duration: isArabic ? '٦٠ دقيقة' : '60 minutes', type: 'interactive' },
            { title: isArabic ? 'تقييم الحفظ والمراجعة' : 'Memorization Assessment', duration: isArabic ? '٩٠ دقيقة' : '90 minutes', type: 'assessment' }
          ]
        }
      ]
    }
  ];

  // Function to render lesson icon based on type
  const renderLessonIcon = (type) => {
    switch (type) {
      case 'video':
        return <Video className="h-4 w-4 text-emerald-600" />;
      case 'practice':
        return <Mic className="h-4 w-4 text-purple-600" />;
      case 'interactive':
        return <Users className="h-4 w-4 text-blue-600" />;
      case 'assessment':
        return <Award className="h-4 w-4 text-gold-500" />;
      default:
        return <Book className="h-4 w-4 text-emerald-600" />;
    }
  };

  return (
    <div dir={isArabic ? 'rtl' : 'ltr'} className={`min-h-screen font-sans ${isArabic ? 'font-arabic' : ''} bg-gray-50`}>
      {/* Top Banner */}
      <div className="bg-gradient-to-r from-emerald-900 to-green-800 py-20 text-white">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              {isArabic ? 'مسارات التعلم والمناهج الدراسية' : 'Learning Paths & Curriculum'}
            </h1>
            <p className="text-lg text-gray-100">
              {isArabic 
                ? 'استكشف دوراتنا المتخصصة في تعليم القرآن الكريم واللغة العربية، مصممة لتناسب جميع المستويات والأهداف' 
                : 'Explore our specialized courses in Quran and Arabic language learning, designed for all levels and goals'}
            </p>
            <div className="mt-8">
              <button
                onClick={toggleLanguage}
                className="bg-transparent border border-gold-400 text-gold-400 px-4 py-2 rounded-lg hover:bg-gold-400 hover:text-emerald-900 transition"
              >
                {isArabic ? 'English' : 'العربية'}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Course Filter & Navigation */}
      <div className="bg-white border-b shadow-sm">
        <div className="container mx-auto px-4">
          <div className="flex flex-wrap py-4">
            <div className="flex items-center text-emerald-900 mr-8 mb-2">
              <span className="font-semibold">{isArabic ? 'تصفية حسب:' : 'Filter by:'}</span>
            </div>
            <div className="flex flex-wrap gap-2">
              <button className="px-4 py-2 rounded-full text-sm bg-emerald-600 text-white hover:bg-emerald-700 transition">
                {isArabic ? 'جميع الدورات' : 'All Courses'}
              </button>
              <button className="px-4 py-2 rounded-full text-sm bg-emerald-100 text-emerald-700 hover:bg-emerald-200 transition">
                {isArabic ? 'القرآن الكريم' : 'Quran'}
              </button>
              <button className="px-4 py-2 rounded-full text-sm bg-emerald-100 text-emerald-700 hover:bg-emerald-200 transition">
                {isArabic ? 'اللغة العربية' : 'Arabic Language'}
              </button>
              <button className="px-4 py-2 rounded-full text-sm bg-emerald-100 text-emerald-700 hover:bg-emerald-200 transition">
                {isArabic ? 'التجويد' : 'Tajweed'}
              </button>
              <button className="px-4 py-2 rounded-full text-sm bg-emerald-100 text-emerald-700 hover:bg-emerald-200 transition">
                {isArabic ? 'الحفظ' : 'Memorization'}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Course Listing */}
      <div className="container mx-auto px-4 py-12">
        <div className="space-y-8">
          {courses.map((course, courseIndex) => (
            <div key={course.id} className="bg-white rounded-xl shadow-md overflow-hidden">
              {/* Course Header */}
              <div 
                className={`cursor-pointer ${expandedCourse === courseIndex ? 'bg-emerald-50' : ''}`}
                onClick={() => toggleCourse(courseIndex)}
              >
                <div className="md:flex">
                  <div className="md:flex-shrink-0 md:w-64 h-48">
                    <img
                      className="h-48 w-full object-cover md:h-full md:w-64"
                      src={course.image}
                      alt={course.title}
                    />
                  </div>
                  <div className="p-6 flex-1">
                    <div className="flex justify-between items-start">
                      <div>
                        <h2 className="text-2xl font-bold text-emerald-900 mb-2">{course.title}</h2>
                        <p className="text-emerald-700 mb-4">{course.description}</p>
                        
                        <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm">
                          <div className="flex items-center text-gray-600">
                            <Clock className="h-4 w-4 mr-1" />
                            <span>{course.duration}</span>
                          </div>
                          <div className="flex items-center text-gray-600">
                            <Book className="h-4 w-4 mr-1" />
                            <span>{course.lessons}</span>
                          </div>
                          <div className="flex items-center text-gray-600">
                            <Users className="h-4 w-4 mr-1" />
                            <span>{course.students} {isArabic ? 'طالب' : 'students'}</span>
                          </div>
                          <div className="flex items-center text-amber-500">
                            <Star className="h-4 w-4 mr-1 fill-current" />
                            <span>{course.rating} ({course.reviews})</span>
                          </div>
                        </div>
                      </div>
                      <ChevronDown 
                        className={`h-6 w-6 text-emerald-600 transition-transform ${expandedCourse === courseIndex ? 'transform rotate-180' : ''}`}
                      />
                    </div>
                    
                    <div className="mt-4">
                      <div className="flex flex-wrap items-center gap-2">
                        <div className="text-sm font-semibold text-emerald-700">
                          {isArabic ? 'المعلمون:' : 'Instructors:'}
                        </div>
                        {course.instructors.map((instructor, i) => (
                          <div key={i} className="flex items-center">
                            <img 
                              src={instructor.image} 
                              alt={instructor.name} 
                              className="w-8 h-8 rounded-full object-cover border-2 border-emerald-200"
                            />
                            <span className="ml-2 text-sm text-gray-700">{instructor.name}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Expanded Course Content */}
              {expandedCourse === courseIndex && (
                <div className="border-t border-gray-200">
                  <div className="px-6 py-4 bg-emerald-50">
                    <div className="flex items-center mb-4">
                      <h3 className="text-lg font-semibold text-emerald-800">
                        {isArabic ? 'محتوى الدورة' : 'Course Content'}
                      </h3>
                      <div className="ml-auto text-sm text-gray-600">
                        {course.modules.length} {isArabic ? 'وحدات' : 'modules'}, {course.lessons} {isArabic ? 'درساً' : 'lessons'}
                      </div>
                    </div>

                    <div className="space-y-4">
                      {course.modules.map((module, moduleIndex) => (
                        <div key={moduleIndex} className="border border-gray-200 rounded-lg bg-white overflow-hidden">
                          <div 
                            className="flex justify-between items-center p-4 cursor-pointer hover:bg-gray-50"
                            onClick={() => toggleModule(courseIndex, moduleIndex)}
                          >
                            <div className="flex items-center">
                              <Book className="h-5 w-5 text-emerald-600 mr-2" />
                              <h4 className="font-medium text-gray-800">{module.title}</h4>
                            </div>
                            <div className="flex items-center">
                              <span className="text-sm text-gray-600 mr-3">
                                {module.lessons.length} {isArabic ? 'دروس' : 'lessons'}
                              </span>
                              <ChevronDown 
                                className={`h-5 w-5 text-gray-500 transition-transform ${expandedModule === `${courseIndex}-${moduleIndex}` ? 'transform rotate-180' : ''}`}
                              />
                            </div>
                          </div>

                          {/* Expanded Module Content */}
                          {expandedModule === `${courseIndex}-${moduleIndex}` && (
                            <div className="border-t border-gray-200 divide-y divide-gray-200">
                              {module.lessons.map((lesson, lessonIndex) => (
                                <div key={lessonIndex} className="p-4 hover:bg-gray-50">
                                  <div className="flex items-center">
                                    <div className="mr-3">
                                      {renderLessonIcon(lesson.type)}
                                    </div>
                                    <div className="flex-1">
                                      <h5 className="text-gray-800">{lesson.title}</h5>
                                      <div className="flex items-center mt-1">
                                        <Clock className="h-3 w-3 text-gray-500 mr-1" />
                                        <span className="text-xs text-gray-500">{lesson.duration}</span>
                                      </div>
                                    </div>
                                    <button className="px-3 py-1 rounded text-sm bg-emerald-100 text-emerald-700 hover:bg-emerald-200 transition">
                                      {isArabic ? 'معاينة' : 'Preview'}
                                    </button>
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="px-6 py-4 bg-white border-t border-gray-200 flex justify-between items-center">
                    <div>
                      <span className="text-2xl font-bold text-emerald-900">
                        {isArabic ? '$٥٩.٩٩' : '$59.99'}
                      </span>
                      <span className="text-sm text-gray-500 line-through mx-2">
                        {isArabic ? '$٧٩.٩٩' : '$79.99'}
                      </span>
                      <span className="text-sm bg-red-100 text-red-700 px-2 py-1 rounded">
                        {isArabic ? '٢٥% خصم' : '25% OFF'}
                      </span>
                    </div>
                    <div className="flex gap-3">
                      <button className="px-4 py-2 rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 transition">
                        {isArabic ? 'اشترك الآن' : 'Enroll Now'}
                      </button>
                      <button className="px-4 py-2 rounded-lg border border-emerald-600 text-emerald-600 hover:bg-emerald-50 transition">
                        {isArabic ? 'جلسة تجريبية' : 'Free Trial'}
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* FAQ Section */}
      <div className="bg-emerald-50 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto">
            <h2 className="text-3xl font-bold text-center text-emerald-900 mb-8">
              {isArabic ? 'الأسئلة الشائعة حول الدورات' : 'Frequently Asked Questions About Courses'}
            </h2>
            
            <div className="space-y-4">
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-emerald-800 mb-2">
                  {isArabic ? 'كيف تتم الدروس المباشرة؟' : 'How do the live classes work?'}
                </h3>
                <p className="text-gray-700">
                  {isArabic 
                    ? 'تُعقد الدروس المباشرة عبر منصة زووم بأوقات محددة حسب جدولك المفضل. يمكنك التفاعل مباشرة مع المعلم، وطرح الأسئلة، والمشاركة في التمارين العملية. كما يتم تسجيل الدروس لتتمكن من مراجعتها لاحقاً.'
                    : 'Live classes are conducted via Zoom at scheduled times based on your preferred schedule. You can interact directly with the teacher, ask questions, and participate in practical exercises. Classes are recorded so you can review them later.'}
                </p>
              </div>
              
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-emerald-800 mb-2">
                  {isArabic ? 'هل يمكنني الدراسة وفق جدولي الخاص؟' : 'Can I study according to my own schedule?'}
                </h3>
                <p className="text-gray-700">
                  {isArabic 
                    ? 'نعم، نحن نوفر خيارات مرنة للدراسة. يمكنك اختيار الأوقات التي تناسبك للدروس المباشرة، كما يمكنك الوصول إلى المحتوى المسجل والتمارين في أي وقت من خلال منصتنا التعليمية وتطبيق رَتِّل.'
                    : 'Yes, we provide flexible study options. You can choose times that suit you for live lessons, and you can access recorded content and exercises anytime through our learning platform and the Rateel app.'}
                </p>
              </div>
              
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-emerald-800 mb-2">
                  {isArabic ? 'هل أحتاج إلى معرفة مسبقة باللغة العربية لدراسة التجويد؟' : 'Do I need prior knowledge of Arabic to study Tajweed?'}
                </h3>
                <p className="text-gray-700">
                  {isArabic 
                    ? 'لا، يمكنك البدء من الصفر. تبدأ دوراتنا بأساسيات القراءة والنطق، ونقدم دعماً خاصاً للمبتدئين. يمكنك أيضاً دراسة اللغة العربية بالتزامن مع التجويد لفهم أعمق.'
                    : 'No, you can start from scratch. Our courses begin with the basics of reading and pronunciation, and we provide special support for beginners. You can also study Arabic language concurrently with Tajweed for deeper understanding.'}
                </p>
              </div>
              
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-emerald-800 mb-2">
                  {isArabic ? 'كيف يتم تقييم تقدمي في الدورة؟' : 'How is my progress in the course evaluated?'}
                </h3>
                <p className="text-gray-700">
                  {isArabic 
                    ? 'نستخدم نظام تقييم شامل يتضمن تقييمات دورية، اختبارات قصيرة، وتسميع للحفظ. يقدم المعلمون تقارير تقدم منتظمة مع ملاحظات شخصية، ويمكنك أيضاً متابعة تقدمك في تطبيق رَتِّل.'
                    : 'We use a comprehensive evaluation system that includes periodic assessments, quizzes, and memorization recitation. Teachers provide regular progress reports with personalized feedback, and you can also track your progress in the Rateel app.'}
                </p>
              </div>
            </div>
            
            <div className="text-center mt-10">
              <button className="px-6 py-3 rounded-lg bg-gold-500 text-emerald-900 hover:bg-gold-600 font-bold transition">
                {isArabic ? 'استشارة مجانية مع مرشد تعليمي' : 'Free Consultation with Education Advisor'}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Call to Action */}
      <div className="bg-gradient-to-r from-emerald-900 to-green-800 py-16 text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">
            {isArabic ? 'ابدأ رحلة التعلم اليوم' : 'Start Your Learning Journey Today'}
          </h2>
          <p className="text-lg mb-8 max-w-2xl mx-auto">
            {isArabic 
              ? 'انضم إلى آلاف الطلاب حول العالم الذين يتعلمون القرآن واللغة العربية مع أكاديمية رَتِّل'
              : 'Join thousands of students around the world learning Quran and Arabic with Rateel Academy'}
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            <button className="px-6 py-3 rounded-lg bg-white text-emerald-900 hover:bg-gray-100 font-bold transition">
              {isArabic ? 'استكشف جميع الدورات' : 'Explore All Courses'}
            </button>
            <button className="px-6 py-3 rounded-lg bg-gold-500 text-emerald-900 hover:bg-gold-600 font-bold transition">
              {isArabic ? 'ابدأ التجربة المجانية' : 'Start Free Trial'}
            </button>
          </div>
        </div>
      </div>

      {/* Add custom style for the gold color that matches the Rateel app */}
      <style jsx global>{`
        :root {
          --color-gold-400: #FFD700;
          --color-gold-500: #DAA520;
          --color-gold-600: #B8860B;
        }
        
        .text-gold-400 {
          color: var(--color-gold-400);
        }
        
        .bg-gold-400 {
          background-color: var(--color-gold-400);
        }
        
        .text-gold-500 {
          color: var(--color-gold-500);
        }
        
        .bg-gold-500 {
          background-color: var(--color-gold-500);
        }
        
        .text-gold-600 {
          color: var(--color-gold-600);
        }
        
        .bg-gold-600 {
          background-color: var(--color-gold-600);
        }
        
        .border-gold-400 {
          border-color: var(--color-gold-400);
        }
        
        .border-gold-500 {
          border-color: var(--color-gold-500);
        }
        
        .border-gold-600 {
          border-color: var(--color-gold-600);
        }
        
        /* Add custom Arabic font */
        .font-arabic {
          font-family: 'Cairo', sans-serif;
        }
      `}</style>
    </div>
  );
}

```

<details><summary>risultato tool</summary>

```
OK
```
</details>
