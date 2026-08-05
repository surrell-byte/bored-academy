#!/usr/bin/env bash
set -euo pipefail
# Run this from your project root: /Users/russell/Downloads/bored-academy-1-1
ROOT="$(pwd)"
echo "Applying CET-4 course into: $ROOT"

# 1. New data file: assets/js/data/cet4-data.js
mkdir -p assets/js/data
cat > assets/js/data/cet4-data.js <<'CET4_DATA_EOF'
// Bored Academy — CET-4 Master Course lesson data
// Lessons 1-8 (Module 1: Building the Foundation, Module 2: Listening Mastery)
// built in full detail. Lessons 9-24 are stubbed as "coming soon" so the
// sidebar reflects the full 24-lesson syllabus; replace each stub's `html`
// once that lesson is written.
window.COURSE_DATA = [
{
  unit:"Module 1 — Building the Foundation",
  id:"1",
  title:"Understanding the CET-4 Exam & Diagnostic Assessment",
  objectives:[
    "Explain the structure of the CET-4 exam.",
    "Understand how each section is scored.",
    "Identify the skills tested in Writing, Listening, Reading, and Translation.",
    "Complete a diagnostic assessment.",
    "Set personal learning goals for the course."
  ],
  success:[
    "Describe the four sections of the CET-4 and their approximate timing.",
    "Use today's 10 exam-related vocabulary words correctly.",
    "Correct common present-tense and subject-verb errors.",
    "Answer diagnostic quiz questions with reasonable accuracy.",
    "Identify one personal goal for the course."
  ],
  vocab:[
    ["candidate","考生 — person taking an exam"],
    ["passage","文章 — a reading text"],
    ["transcript","听力原文 — written version of audio"],
    ["summarize","总结 — give the main idea"],
    ["infer","推断 — understand indirectly"],
    ["accurate","准确的 — correct"],
    ["distractor","干扰项 — wrong answer designed to confuse"],
    ["paragraph","段落 — a group of sentences"],
    ["evidence","证据 — supporting information"],
    ["fluent","流利的 — speaking smoothly"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Level:</strong> Intermediate (CEFR B1–B2) &nbsp;|&nbsp; <strong>Focus:</strong> Exam Orientation &amp; Diagnostic</p>
  <p>Build a strong foundation for success in the CET-4 by understanding the exam format, identifying strengths and weaknesses, and introducing effective study strategies.</p>
  <h4>Warm-up Discussion</h4><ul>
  <li>Why are you taking the CET-4?</li>
  <li>Have you taken it before?</li>
  <li>Which section do you think is the easiest / worries you the most?</li>
  <li>How often do you study English, and what activities do you enjoy?</li>
  <li>What score do you hope to get?</li>
  </ul>
  <h4>Exam Structure</h4>
  <table class="data-table"><tr><th>Section</th><th>Approx. Time</th><th>Skills Tested</th></tr>
  <tr><td>Writing</td><td>30 minutes</td><td>Essay writing</td></tr>
  <tr><td>Listening</td><td>25 minutes</td><td>News, conversations, lectures</td></tr>
  <tr><td>Reading</td><td>40 minutes</td><td>Vocabulary, matching, careful reading</td></tr>
  <tr><td>Translation</td><td>30 minutes</td><td>Chinese → English</td></tr>
  </table>
  <h4>Important Tips</h4><ul>
  <li>Listening is played only once.</li>
  <li>Read questions before listening.</li>
  <li>Manage time carefully; don't spend too long on difficult questions.</li>
  <li>Write neatly and clearly.</li>
  </ul>
  <h4>Grammar Review — Common Errors</h4>
  <div class="misconceptions">
  <div class="row wrong">❌ She go to school every day.</div>
  <div class="row right">✔ She goes to school every day.</div>
  <div class="row wrong">❌ He don't like coffee.</div>
  <div class="row right">✔ He doesn't like coffee.</div>
  <div class="row wrong">❌ I am study English.</div>
  <div class="row right">✔ I am studying English.</div>
  <div class="row wrong">❌ Yesterday I go shopping.</div>
  <div class="row right">✔ Yesterday I went shopping.</div>
  <div class="row wrong">❌ She have many books.</div>
  <div class="row right">✔ She has many books.</div>
  </div>
  <h4>Reading Practice — Why Learn English?</h4>
  <p>English is one of the most widely spoken languages in the world. It is used in business, science, technology, education, and international communication. Many Chinese university students study English because it helps them find better jobs, continue their education abroad, and communicate with people from different countries. Learning English also gives students access to books, movies, research papers, and online resources. Although learning a new language can be challenging, regular practice helps learners become more confident and successful.</p>
  <p><strong>Questions:</strong> Why do many Chinese students study English? Name two fields where English is used. What can students access by learning English? Is learning English always easy? What helps students improve?</p>
  <div class="example-box"><strong>Answers:</strong> Better jobs, further study, international communication · Business, science, technology, education (any two) · Books, movies, research papers, online resources · No · Regular practice.</div>
  <h4>Listening Activity (Teacher Script, read twice)</h4>
  <p><em>"Good morning everyone. Today we will discuss effective ways to learn English. First, remember that learning a language takes time and patience. Reading English books, listening to podcasts, and speaking every day are excellent habits. Don't be afraid to make mistakes because mistakes help you improve. If you practice consistently, you will become more confident."</em></p>
  <h4>Writing Practice</h4>
  <p><strong>Prompt (100–120 words):</strong> Why Do You Want to Improve Your English? Use: Introduction → Two reasons → Conclusion.</p>
  <p><strong>Useful expressions:</strong> In my opinion... · First of all... · Another reason is... · As a result... · Therefore... · In conclusion...</p>
  <h4>Diagnostic Quiz</h4><ol>
  <li>She _____ English every evening. (A. study B. studies C. studying)</li>
  <li>Yesterday we _____ a movie. (A. watch B. watched C. watching)</li>
  <li>"Accurate" means: (A. incorrect B. careful C. correct)</li>
  <li>Which section tests Chinese to English? (A. Listening B. Translation C. Reading)</li>
  <li>Which skill usually improves vocabulary fastest? (A. Reading B. Sleeping C. Waiting)</li>
  </ol>
  <div class="example-box"><strong>Answers:</strong> 1-B, 2-B, 3-C, 4-B, 5-A</div>
  <h4>Homework</h4><ul>
  <li>Learn the 10 vocabulary words: English + Chinese meaning + one original sentence each.</li>
  <li>Read a 150–250 word English news article; note the main idea, three new words, one interesting fact.</li>
  <li>Write a 100–120 word essay: "Why Is English Important for University Students?" using ≥5 of today's words.</li>
  <li>Self-reflection: Which CET-4 section will be hardest for you, and why? What is one goal for this course?</li>
  </ul>
  <div class="example-box"><strong>Key Takeaway:</strong> Steady practice and strategy are just as important as raw language knowledge — this course builds both.</div>
  </div>`,
  quiz:[
    {q:"How long is the CET-4 Writing section?",opts:["25 minutes","30 minutes","40 minutes","60 minutes"],a:1},
    {q:"How many times is the listening recording played?",opts:["Once","Twice","Three times","As many times as needed"],a:0},
    {q:"\"Distractor\" means:",opts:["A correct answer","A wrong answer designed to confuse","A reading passage","A grading scale"],a:1},
    {q:"Which is correct?",opts:["He don't like coffee.","He doesn't like coffee.","He not like coffee.","He isn't like coffee."],a:1}
  ]
},
{
  unit:"Module 1 — Building the Foundation",
  id:"2",
  title:"Essential Grammar I: Present Tenses, Agreement & Articles",
  objectives:[
    "Use the four present tenses correctly.",
    "Apply subject–verb agreement accurately.",
    "Use articles (a, an, the, Ø) correctly.",
    "Recognize common CET-4 grammar errors.",
    "Write more accurate sentences for the writing and translation sections."
  ],
  success:[
    "Form Present Simple and Present Continuous correctly in positive, negative and question forms.",
    "Apply subject-verb agreement rules, including tricky cases like everyone/news.",
    "Choose a / an / the / Ø correctly in context.",
    "Correct CET-4-style grammar errors confidently.",
    "Write a short paragraph using both present tenses and correct articles."
  ],
  vocab:[
    ["achieve","实现"],["academic","学术的"],["analyze","分析"],["arrange","安排"],["attend","参加"],
    ["average","平均的"],["benefit","好处"],["challenge","挑战"],["communicate","交流"],["compare","比较"],
    ["complete","完成"],["concentrate","专注"],["create","创造"],["develop","发展"],["improve","提高"],
    ["include","包括"],["increase","增加"],["participate","参与"],["prepare","准备"],["succeed","成功"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Writing, Reading, Translation, Grammar Accuracy</p>
  <h4>Grammar Focus 1 — Present Simple</h4>
  <p><strong>Use:</strong> daily routines, habits, facts, timetables. <strong>Signal words:</strong> always, usually, often, sometimes, every day, never.</p>
  <table class="data-table"><tr><th>Form</th><th>Structure</th><th>Example</th></tr>
  <tr><td>Positive</td><td>Subject + Verb</td><td>She studies every day.</td></tr>
  <tr><td>Negative</td><td>Subject + do/does not + verb</td><td>He doesn't like coffee.</td></tr>
  <tr><td>Question</td><td>Do/Does + subject + verb?</td><td>Does she study English?</td></tr>
  </table>
  <h4>Grammar Focus 2 — Present Continuous</h4>
  <p><strong>Use:</strong> actions happening now, temporary situations, future arrangements. <strong>Signal words:</strong> now, at the moment, currently, today, right now.</p>
  <p><strong>Structure:</strong> Subject + am/is/are + verb-ing — <em>I am reading. She is studying. They are watching TV.</em></p>
  <h4>Grammar Focus 3 — Subject–Verb Agreement</h4>
  <table class="data-table"><tr><th>Rule</th><th>Example</th></tr>
  <tr><td>Singular subject → singular verb</td><td>The teacher teaches English.</td></tr>
  <tr><td>Plural subject → plural verb</td><td>The students study every day.</td></tr>
  <tr><td>Everyone / somebody / nobody = singular</td><td>Everyone enjoys music. Somebody is waiting.</td></tr>
  <tr><td>Money, news, mathematics = singular</td><td>The news is interesting. Mathematics is difficult.</td></tr>
  </table>
  <div class="misconceptions">
  <div class="row wrong">❌ He like football.</div><div class="row right">✔ He likes football.</div>
  <div class="row wrong">❌ My parents goes shopping.</div><div class="row right">✔ My parents go shopping.</div>
  <div class="row wrong">❌ Everyone have homework.</div><div class="row right">✔ Everyone has homework.</div>
  <div class="row wrong">❌ The news are surprising.</div><div class="row right">✔ The news is surprising.</div>
  </div>
  <h4>Grammar Focus 4 — Articles</h4>
  <table class="data-table"><tr><th>Article</th><th>Use</th><th>Example</th></tr>
  <tr><td>a / an</td><td>First mention of something</td><td>I bought a book. She is an engineer.</td></tr>
  <tr><td>the</td><td>Both people know what you mean</td><td>Close the door. The moon is beautiful.</td></tr>
  <tr><td>Ø (no article)</td><td>Languages, meals, most countries, school subjects</td><td>I study English. We had breakfast. China is large.</td></tr>
  </table>
  <h4>CET-4 Error Correction</h4>
  <div class="misconceptions">
  <div class="row wrong">❌ He don't know the answer.</div><div class="row right">✔ He doesn't know the answer.</div>
  <div class="row wrong">❌ My brother study engineering.</div><div class="row right">✔ My brother studies engineering.</div>
  <div class="row wrong">❌ I am usually go to bed at eleven.</div><div class="row right">✔ I usually go to bed at eleven.</div>
  <div class="row wrong">❌ She is knowing the answer.</div><div class="row right">✔ She knows the answer.</div>
  <div class="row wrong">❌ There are a university near my home.</div><div class="row right">✔ There is a university near my home.</div>
  </div>
  <h4>Reading Practice</h4>
  <p>Many university students want to improve their English because it is important for both their studies and future careers. Some students read English books every day, while others watch English videos online. Many also join English clubs where they can practice speaking with classmates. Although learning a language requires patience, regular practice helps students become more confident and successful.</p>
  <h4>Writing Practice</h4>
  <p><strong>Topic (100–120 words):</strong> My Daily Study Routine — include when/where you study, what you usually study, what you are studying this week, and why English is important. Use Present Simple, Present Continuous, and at least three articles correctly.</p>
  <h4>Homework</h4><ul>
  <li>Correct 5 grammar mistakes (don't/doesn't, reading now, everyone has, go to school, an → a university).</li>
  <li>Learn 20 academic words (achieve, academic, analyze, arrange, attend, average, benefit, challenge, communicate, compare, complete, concentrate, create, develop, improve, include, increase, participate, prepare, succeed) with meanings and original sentences.</li>
  <li>Write a 120-word paragraph "How I Improve My English" using ≥10 vocabulary words, 8 Present Simple verbs, 4 Present Continuous verbs, and correct articles.</li>
  </ul>
  <div class="example-box"><strong>Key Takeaway:</strong> The most common CET-4 grammar mistakes for Chinese learners are omitting the third-person singular -s, confusing a/an, and overusing the present continuous. Accuracy here pays off directly in Writing and Translation scores.</div>
  </div>`,
  quiz:[
    {q:"Which sentence is correct?",opts:["My father work in a hospital.","My father works in a hospital.","My father working in a hospital.","My father is work in a hospital."],a:1},
    {q:"\"The news ___ surprising.\"",opts:["are","is","were","have"],a:1},
    {q:"Which needs no article (Ø)?",opts:["___ apple","___ university","___ China","___ book on the table"],a:2},
    {q:"Correct the error: \"I am usually go to bed at eleven.\"",opts:["I am usually going to bed at eleven.","I usually go to bed at eleven.","I usually going to bed at eleven.","I am usual go to bed at eleven."],a:1}
  ]
},
{
  unit:"Module 1 — Building the Foundation",
  id:"3",
  title:"Essential Grammar II: Past Tenses, Present Perfect & Passive Voice",
  objectives:[
    "Use the Past Simple correctly.",
    "Distinguish between the Past Simple and the Present Perfect.",
    "Form and use the Passive Voice.",
    "Avoid common grammar mistakes found in CET-4.",
    "Write accurate sentences using all three grammar points."
  ],
  success:[
    "Choose correctly between Past Simple and Present Perfect based on time reference.",
    "Form the Passive Voice (be + past participle) accurately.",
    "Correct common CET-4 tense and voice errors.",
    "Translate Chinese sentences using the correct tense/voice.",
    "Write a paragraph using Past Simple, Present Perfect, and Passive Voice together."
  ],
  vocab:[
    ["account","账户；解释"],["advance","进步；前进"],["apply","申请；应用"],["approach","方法；接近"],["audience","观众"],
    ["available","可获得的"],["behavior","行为"],["career","职业"],["conduct","实施；行为"],["consume","消费"],
    ["determine","决定"],["encourage","鼓励"],["evidence","证据"],["explore","探索"],["feature","特点"],
    ["influence","影响"],["maintain","保持"],["perform","表现；执行"],["resource","资源"],["value","价值"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Grammar, Reading, Writing, Translation</p>
  <h4>Grammar Focus 1 — Past Simple</h4>
  <p><strong>Use:</strong> finished actions, past habits, specific times. <strong>Time expressions:</strong> yesterday, last week, last year, two days ago, in 2024.</p>
  <table class="data-table"><tr><th>Form</th><th>Structure</th><th>Example</th></tr>
  <tr><td>Positive</td><td>Subject + Verb (past)</td><td>I visited Beijing last year.</td></tr>
  <tr><td>Negative</td><td>Subject + did not + base verb</td><td>They didn't watch TV.</td></tr>
  <tr><td>Question</td><td>Did + subject + base verb?</td><td>Did you finish your homework?</td></tr>
  </table>
  <h4>Grammar Focus 2 — Present Perfect</h4>
  <p><strong>Structure:</strong> Subject + have/has + past participle. <strong>Signal words:</strong> already, just, yet, ever, never, since, for.</p>
  <table class="data-table"><tr><th>Past Simple</th><th>Present Perfect</th></tr>
  <tr><td>yesterday</td><td>today</td></tr>
  <tr><td>last week</td><td>already</td></tr>
  <tr><td>in 2025</td><td>just</td></tr>
  <tr><td>finished time</td><td>unfinished time</td></tr>
  <tr><td>I went.</td><td>I have gone.</td></tr>
  </table>
  <div class="misconceptions">
  <div class="row wrong">❌ I have seen him yesterday.</div><div class="row right">✔ I saw him yesterday.</div>
  <div class="row wrong">❌ I visited Beijing three times last year.</div><div class="row right">✔ I have visited Beijing three times.</div>
  </div>
  <h4>Grammar Focus 3 — Passive Voice</h4>
  <p>Frequent in reading passages, translation, and academic writing. <strong>Structure:</strong> be + past participle.</p>
  <table class="data-table"><tr><th>Active</th><th>Passive</th></tr>
  <tr><td>The teacher explains the lesson.</td><td>The lesson is explained by the teacher.</td></tr>
  <tr><td>They built the library last year.</td><td>The library was built last year.</td></tr>
  <tr><td>Students clean the classroom every day.</td><td>The classroom is cleaned every day.</td></tr>
  </table>
  <p>Use the passive when the action matters more than the doer, the doer is unknown, or the writing is formal/academic.</p>
  <h4>Common CET-4 Errors</h4>
  <div class="misconceptions">
  <div class="row wrong">❌ I have finished my homework yesterday.</div><div class="row right">✔ I finished my homework yesterday.</div>
  <div class="row wrong">❌ She have visited Beijing.</div><div class="row right">✔ She has visited Beijing.</div>
  <div class="row wrong">❌ English speak by millions.</div><div class="row right">✔ English is spoken by millions.</div>
  <div class="row wrong">❌ The homework finish yesterday.</div><div class="row right">✔ The homework was finished yesterday.</div>
  <div class="row wrong">❌ They has completed the work.</div><div class="row right">✔ They have completed the work.</div>
  </div>
  <h4>Translation Practice</h4><ol>
  <li>英语在世界各地被广泛使用。 → English is widely spoken around the world.</li>
  <li>我已经完成了作业。 → I have finished my homework.</li>
  <li>她昨天买了一本书。 → She bought a book yesterday.</li>
  <li>这座桥建于二十年前。 → The bridge was built twenty years ago.</li>
  <li>我从小学开始学习英语。 → I have studied English since primary school.</li>
  </ol>
  <h4>Writing Practice</h4>
  <p><strong>Topic (120–150 words):</strong> An Important Experience in My Life. Use ≥5 Past Simple verbs, 3 Present Perfect sentences, 2 Passive Voice sentences, and linking words (First, Then, After that, Finally, As a result).</p>
  <h4>Homework</h4><ul>
  <li>Correct 5 grammar mistakes mixing Past Simple, Present Perfect and Passive Voice.</li>
  <li>Learn 20 vocabulary words (account, advance, apply, approach, audience, available, behavior, career, conduct, consume, determine, encourage, evidence, explore, feature, influence, maintain, perform, resource, value).</li>
  <li>Translate 5 more Chinese sentences into English.</li>
  <li>Write a 150-word essay "How Technology Has Changed My Learning" using all three grammar points and ≥10 vocabulary words.</li>
  </ul>
  <div class="example-box"><strong>Key Takeaway:</strong> The Past Simple vs Present Perfect distinction is one of the most common CET-4 challenges — always ask "is this finished time, or connected to now?"</div>
  </div>`,
  quiz:[
    {q:"\"I ___ my homework already.\"",opts:["finished","have finished","finish","was finished"],a:1},
    {q:"Change to passive: \"They built the library last year.\"",opts:["The library built last year.","The library was built last year.","The library is built last year.","The library has built last year."],a:1},
    {q:"Which is correct?",opts:["I have seen him yesterday.","I saw him yesterday.","I have saw him yesterday.","I was see him yesterday."],a:1},
    {q:"\"English ___ by millions of people.\"",opts:["speaks","is spoken","spoke","has speak"],a:1}
  ]
},
{
  unit:"Module 1 — Building the Foundation",
  id:"4",
  title:"Academic Vocabulary I: Word Families, Prefixes, Suffixes & Collocations",
  objectives:[
    "Recognise common academic vocabulary found in the CET-4.",
    "Understand word families and how different word forms are used.",
    "Identify common prefixes and suffixes.",
    "Learn important collocations.",
    "Guess the meaning of unfamiliar words from context."
  ],
  success:[
    "Choose the correct word form (verb/noun/adjective/adverb) in context.",
    "Identify the meaning added by a prefix or suffix.",
    "Use at least 10 verb+noun academic collocations correctly.",
    "Apply three context-clue strategies to guess unknown words.",
    "Write a paragraph using word families, prefixes, suffixes and collocations."
  ],
  vocab:[
    ["access","获取；通道"],["affect","影响"],["analyse","分析"],["approach","方法"],["assess","评估"],
    ["assume","假设"],["available","可获得的"],["benefit","好处"],["concept","概念"],["conclude","得出结论"],
    ["consequence","后果"],["demonstrate","展示；证明"],["efficient","高效的"],["establish","建立"],["evaluate","评价"],
    ["evidence","证据"],["factor","因素"],["function","功能"],["identify","识别"],["indicate","表明"],
    ["issue","问题"],["method","方法"],["occur","发生"],["participate","参与"],["require","需要"],
    ["respond","回应"],["significant","重要的"],["strategy","策略"],["theory","理论"],["variable","变量"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Vocabulary, Reading, Writing, Translation</p>
  <h4>Part 1 — Word Families</h4>
  <p>One root word can create many different words; learning word families helps you recognise unfamiliar vocabulary in reading passages.</p>
  <table class="data-table"><tr><th>Verb</th><th>Noun</th><th>Adjective</th><th>Other</th></tr>
  <tr><td>develop</td><td>development</td><td>developed / developing</td><td>developer (n.)</td></tr>
  <tr><td>create</td><td>creation</td><td>creative</td><td>creatively (adv.), creator (n.)</td></tr>
  <tr><td>educate</td><td>education</td><td>educational</td><td>educator (n.)</td></tr>
  </table>
  <h4>Part 2 — Common Prefixes</h4>
  <table class="data-table"><tr><th>Prefix</th><th>Meaning</th><th>Example</th></tr>
  <tr><td>un-</td><td>not</td><td>unhappy</td></tr>
  <tr><td>dis-</td><td>opposite</td><td>disagree</td></tr>
  <tr><td>re-</td><td>again</td><td>rebuild</td></tr>
  <tr><td>pre-</td><td>before</td><td>preview</td></tr>
  <tr><td>post-</td><td>after</td><td>postgraduate</td></tr>
  <tr><td>inter-</td><td>between</td><td>international</td></tr>
  <tr><td>over-</td><td>too much</td><td>overwork</td></tr>
  <tr><td>under-</td><td>too little</td><td>underpaid</td></tr>
  </table>
  <h4>Part 3 — Common Suffixes</h4>
  <table class="data-table"><tr><th>Suffix</th><th>Part of Speech</th><th>Example</th></tr>
  <tr><td>-tion</td><td>noun</td><td>education</td></tr>
  <tr><td>-ment</td><td>noun</td><td>development</td></tr>
  <tr><td>-ness</td><td>noun</td><td>happiness</td></tr>
  <tr><td>-ity</td><td>noun</td><td>ability</td></tr>
  <tr><td>-er</td><td>noun</td><td>teacher</td></tr>
  <tr><td>-ful</td><td>adjective</td><td>helpful</td></tr>
  <tr><td>-less</td><td>adjective</td><td>careless</td></tr>
  <tr><td>-able</td><td>adjective</td><td>comfortable</td></tr>
  <tr><td>-ive</td><td>adjective</td><td>active</td></tr>
  <tr><td>-ly</td><td>adverb</td><td>carefully</td></tr>
  </table>
  <h4>Part 4 — Academic Collocations</h4>
  <table class="data-table"><tr><th>Verb</th><th>Noun</th></tr>
  <tr><td>make</td><td>progress</td></tr>
  <tr><td>gain</td><td>experience</td></tr>
  <tr><td>reach</td><td>a conclusion</td></tr>
  <tr><td>solve</td><td>a problem</td></tr>
  <tr><td>conduct</td><td>research</td></tr>
  <tr><td>achieve</td><td>success</td></tr>
  <tr><td>face</td><td>challenges</td></tr>
  <tr><td>improve</td><td>skills</td></tr>
  <tr><td>protect</td><td>the environment</td></tr>
  <tr><td>provide</td><td>information</td></tr>
  </table>
  <h4>Part 5 — Guessing Meaning from Context</h4><ul>
  <li><strong>Nearby words:</strong> "The weather was humid, so everyone felt hot and uncomfortable." → humid ≈ hot and wet.</li>
  <li><strong>Examples:</strong> "Many mammals, such as whales, dolphins and elephants..." → mammals ≈ animals like whales and elephants.</li>
  <li><strong>Opposites:</strong> "Unlike his outgoing brother, Tom is quite reserved." → reserved ≈ shy.</li>
  </ul>
  <h4>Reading Practice</h4>
  <p>University students often need strong communication skills. During group projects, they exchange ideas, solve problems together, and complete research. Although academic work can be challenging, students gradually become more confident through regular practice. Many universities also encourage students to participate in volunteer activities because these experiences develop leadership skills and responsibility.</p>
  <h4>Writing Practice</h4>
  <p><strong>Topic (150 words):</strong> The Importance of Lifelong Learning. Use 5 academic collocations, 5 words with prefixes, 5 words with suffixes, and 3 words from the same word family.</p>
  <h4>CET-4 High-Frequency Academic Vocabulary (30 words)</h4>
  <p>access, affect, analyse, approach, assess, assume, available, benefit, concept, conclude, consequence, demonstrate, efficient, establish, evaluate, evidence, factor, function, identify, indicate, issue, method, occur, participate, require, respond, significant, strategy, theory, variable.</p>
  <h4>Homework</h4><ul>
  <li>Complete a word-family table (decide/decision/decisive, improve, communicate, organise, succeed).</li>
  <li>Create one new word using each prefix and suffix taught, with a sentence for each.</li>
  <li>Read a 300–400 word article; find 10 new words, 5 collocations, 3 prefixes, 3 suffixes; write a 60-word summary.</li>
  <li>Write a 150–180 word essay "Why Learning Vocabulary Is More Than Memorising Words" using ≥15 words from today's list and 8 collocations.</li>
  </ul>
  <div class="example-box"><strong>Module 1 Progress Check:</strong> You should now understand the CET-4 format, use present/past/present-perfect tenses and the passive voice accurately, apply subject–verb agreement and articles, and recognise academic vocabulary, word families, prefixes, suffixes and collocations.</div>
  </div>`,
  quiz:[
    {q:"The noun form of \"decide\" is:",opts:["deciding","decision","decisive","decidedly"],a:1},
    {q:"\"Rebuild\" means:",opts:["build badly","build again","build before","build carelessly"],a:1},
    {q:"Which word is an adjective?",opts:["happiness","helpful","carefully","development"],a:1},
    {q:"Which collocation is correct?",opts:["do success","make success","achieve success","take success"],a:2}
  ]
},
{
  unit:"Module 2 — Listening Mastery",
  id:"5",
  title:"Short News Reports: Predicting Answers, Keywords, Numbers & Dates",
  objectives:[
    "Understand the format of CET-4 short news reports.",
    "Predict likely answers before listening.",
    "Identify keywords and distractors.",
    "Listen accurately for numbers, dates, names, and places.",
    "Improve listening confidence through structured practice."
  ],
  success:[
    "Predict a news report's topic from question wording before listening.",
    "Underline keywords (names, numbers, dates, places, verbs) while ignoring extra detail.",
    "Write numbers and dates accurately from dictation.",
    "Recognise distractor signal words (but, however, instead, finally, actually).",
    "Score at least 'Good' on a short news-report mini-test."
  ],
  vocab:[
    ["headline","标题"],["journalist","记者"],["broadcast","广播；播出"],["report","报道"],["witness","目击者"],
    ["authorities","当局"],["investigation","调查"],["emergency","紧急情况"],["rescue","救援"],["victim","受害者"],
    ["suspect","嫌疑人"],["increase","增加"],["decrease","减少"],["announce","宣布"],["estimate","估计"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Listening Comprehension, Note-taking, Main Ideas, Test-taking Strategies</p>
  <h4>Strategy 1 — Predict Before Listening</h4>
  <p>Before the recording starts, ask: Who is speaking? What topic is this? Where/when does it happen? Why is it important? Then think of words related to likely topics (education, weather, transportation, etc.).</p>
  <h4>Strategy 2 — Keywords</h4>
  <p><strong>Listen for:</strong> names, numbers, dates, places, verbs, changes, causes, results. <strong>Ignore:</strong> examples, extra explanations, repeated information.</p>
  <p><em>Example:</em> "The government announced yesterday that over 3,500 university students will receive scholarships beginning in September." Keywords: announced, 3,500, scholarships, September.</p>
  <h4>Strategy 3 — Numbers & Dates</h4>
  <p>CET-4 often tests prices, ages, percentages, distances, times, and dates. Practice writing what you hear as digits: twenty-three thousand → 23,000; six point five million → 6.5 million; forty-eight percent → 48%; July twenty-third → July 23.</p>
  <h4>Listening Practice 1</h4>
  <p><em>"The Ministry of Education announced yesterday that more than 12,000 university students have volunteered to teach in rural areas this summer. The programme will begin on July 15th and continue for eight weeks..."</em></p>
  <p><strong>Questions:</strong> Who made the announcement? How many students volunteered? When does the programme begin? How long will it last? What is its purpose?</p>
  <div class="example-box"><strong>Answers:</strong> The Ministry of Education · 12,000 · July 15 · Eight weeks · Improve education in rural areas.</div>
  <h4>Listening Practice 2</h4>
  <p><em>"Heavy rain caused flooding in several cities yesterday. Emergency workers rescued more than 250 residents, while local schools were closed for two days. Weather experts predict that conditions will improve by the weekend, although some roads remain closed."</em></p>
  <div class="example-box"><strong>Answers:</strong> Heavy rain · More than 250 · Two days · By the weekend · No, some roads remain closed.</div>
  <h4>Recognising Distractors</h4>
  <p><em>"The meeting was originally planned for Monday but was moved to Tuesday."</em> — the correct answer is Tuesday, not Monday. Watch for: but, however, instead, finally, actually, although.</p>
  <h4>Mini Dictation</h4>
  <p><em>"Technology has changed the way people communicate. More university students now attend online lectures, complete assignments electronically, and collaborate with classmates using digital platforms."</em></p>
  <h4>Homework</h4><ul>
  <li>Learn 15 news vocabulary words with Chinese meanings and original sentences.</li>
  <li>Listen to a 2–3 minute English news report; note the topic, three key facts, five new words, and a one-sentence summary.</li>
  <li>Dictation practice with a partner or teacher.</li>
  <li>Write five numbers/dates in digits from dictation.</li>
  <li>Reflect: which listening strategy helped most; which information type (numbers, dates, names, places) is hardest for you?</li>
  </ul>
  <div class="example-box"><strong>Key Takeaway:</strong> Predict before listening, take keyword-only notes, and always choose the corrected/final answer when a signal word introduces a change.</div>
  </div>`,
  quiz:[
    {q:"Before listening, you should:",opts:["Translate every word","Predict the topic","Read the transcript","Close your eyes"],a:1},
    {q:"Which word often introduces a corrected answer?",opts:["But","Very","Really","And"],a:0},
    {q:"If the speaker changes the date, which one should you choose?",opts:["The first date mentioned","The final/corrected date","Either date","Neither date"],a:1},
    {q:"Good listening notes should be:",opts:["Full sentences","Every word said","Keywords only","Translated into Chinese"],a:2}
  ]
},
{
  unit:"Module 2 — Listening Mastery",
  id:"6",
  title:"Long Conversations: Note-Taking, Speaker Attitude & Distractors",
  objectives:[
    "Understand the structure of CET-4 long conversations.",
    "Take effective notes while listening.",
    "Identify speakers' opinions, feelings, and intentions.",
    "Recognise distractors designed to confuse candidates.",
    "Answer multiple-choice questions accurately."
  ],
  success:[
    "Predict the situation of a conversation from the question wording.",
    "Take keyword-and-symbol notes instead of full sentences.",
    "Identify opinion markers (I suppose, I'm afraid, I'd rather...).",
    "Choose the final decision rather than an earlier, corrected option.",
    "Correctly answer 4+ out of 5 comprehension questions per conversation."
  ],
  vocab:[
    ["appointment","预约"],["assignment","作业；任务"],["deadline","截止日期"],["schedule","日程；安排"],["register","注册"],
    ["tuition","学费"],["scholarship","奖学金"],["recommendation","推荐"],["interview","面试"],["application","申请"],
    ["postpone","推迟"],["attend","参加"],["available","有空的；可获得的"],["opportunity","机会"],["professor","教授"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Long Conversations, Note-taking, Opinions &amp; Attitudes, Distractor Recognition</p>
  <h4>Understanding Long Conversations</h4>
  <p>They usually involve two speakers, one main topic, a problem, a solution, opinions and future plans. Typical topics: university life, classes, travel, jobs, shopping, technology, health, research, campus activities.</p>
  <h4>Strategy 1 — Predict the Situation</h4>
  <p>Read the questions first. If they mention "professor", "assignment", "Friday" — predict the conversation is about homework or a university course.</p>
  <h4>Strategy 2 — Effective Note-Taking</h4>
  <p>Don't write complete sentences — write only keywords. <em>"I can't finish my report because my computer stopped working yesterday."</em> → Good notes: <code>report / computer broken / yesterday</code>.</p>
  <table class="data-table"><tr><th>Symbol</th><th>Meaning</th></tr>
  <tr><td>↑</td><td>increase</td></tr><tr><td>↓</td><td>decrease</td></tr><tr><td>→</td><td>result</td></tr>
  <tr><td>+</td><td>and</td></tr><tr><td>?</td><td>question</td></tr><tr><td>✔</td><td>completed</td></tr><tr><td>✗</td><td>problem</td></tr>
  </table>
  <h4>Strategy 3 — Understanding Opinions</h4>
  <p>Speakers often express opinions indirectly: "I suppose...", "I guess...", "I'm afraid...", "It seems...", "I'd rather...", "I don't think...". Pay attention to likes, dislikes, agreement, disagreement, surprise, disappointment.</p>
  <h4>Listening Practice 1 — Student &amp; Professor</h4>
  <p>A student's laptop broke, delaying her report; she had saved her work online, and the professor allows her to submit on Monday instead.</p>
  <div class="example-box"><strong>Answers:</strong> Laptop stopped working · Originally due today · No, she saved it online · Submit on Monday · Professor's attitude: understanding.</div>
  <h4>Listening Practice 2 — Registration</h4>
  <p>A man tells a woman that course registration closes Friday, not the Monday she expected, because the university changed the deadline last week; she will register tomorrow.</p>
  <h4>Recognising Distractors</h4>
  <p><em>"I wanted to travel by train, but I finally booked a flight."</em> → correct answer: flight, not train. Common distractor words: but, however, although, instead, actually, finally, in fact. Always listen until the speaker finishes the idea.</p>
  <h4>Mini Listening Challenge</h4>
  <p><em>"The library will remain open until midnight during examination week. Students must bring their university identification cards to enter after 9 p.m."</em></p>
  <h4>Homework</h4><ul>
  <li>Learn 15 conversation vocabulary words with Chinese meanings and sentences.</li>
  <li>Listen to a 3–5 minute conversation about university life or work; note speakers, topic, problem, solution, and each speaker's opinion.</li>
  <li>Keyword note-taking practice with a partner.</li>
  <li>Role-play a 2-minute student/adviser conversation with a problem, two solutions, and one final decision.</li>
  </ul>
  <div class="example-box"><strong>Key Takeaway:</strong> CET-4 long-conversation questions often test attitude and final decisions, not just facts — listen for fortunately/unfortunately, I'm afraid, and I'm glad, and always take the corrected information after but/however/actually.</div>
  </div>`,
  quiz:[
    {q:"Good note-taking means:",opts:["Writing every word","Writing only keywords","Writing full sentences","Translating into Chinese"],a:1},
    {q:"Which phrase often expresses an opinion?",opts:["I suppose...","Twenty-five.","Last Tuesday.","Room 204."],a:0},
    {q:"A distractor is usually:",opts:["The final decision","Information later corrected","The speaker's conclusion","A true fact"],a:1},
    {q:"Before listening to a long conversation, students should:",opts:["Close the question paper","Predict the situation","Memorise grammar rules","Skip the questions"],a:1}
  ]
},
{
  unit:"Module 2 — Listening Mastery",
  id:"7",
  title:"Lecture Listening: Main Ideas, Supporting Details & Signal Words",
  objectives:[
    "Understand the structure of CET-4 lecture listening tasks.",
    "Identify the speaker's main idea and supporting details.",
    "Recognise common lecture signal words.",
    "Organise notes effectively.",
    "Answer lecture-based multiple-choice questions with confidence."
  ],
  success:[
    "Identify the introduction, main points and conclusion of a short lecture.",
    "Recognise signal words for adding information, giving examples, contrast, cause/effect and conclusion.",
    "Distinguish a lecture's main idea from its supporting details.",
    "Take organised, heading-based notes instead of full sentences.",
    "Answer 4+ out of 5 lecture comprehension questions correctly."
  ],
  vocab:[
    ["lecture","讲座"],["topic","主题"],["audience","听众"],["research","研究"],["evidence","证据"],
    ["data","数据"],["conclusion","结论"],["theory","理论"],["experiment","实验"],["phenomenon","现象"],
    ["analysis","分析"],["factor","因素"],["influence","影响"],["trend","趋势"],["recommendation","建议"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Lecture Listening, Note-taking, Main Ideas, Academic Structure, Signal Words</p>
  <h4>CET-4 Lecture Recordings</h4>
  <p>Usually 2–3 minutes long, spoken by one speaker, organised into clear sections, academic in style. Common topics: education, technology, environment, health, business, psychology, history, science, culture.</p>
  <h4>Lecture Structure</h4><ol>
  <li><strong>Introduction</strong> — introduces the topic and purpose ("Today we are going to discuss...").</li>
  <li><strong>Main Point 1</strong> — explanation, example, evidence.</li>
  <li><strong>Main Point 2</strong> — explanation, evidence.</li>
  <li><strong>Conclusion</strong> — summary, recommendation, prediction.</li>
  </ol>
  <h4>Signal Words</h4>
  <table class="data-table"><tr><th>Function</th><th>Examples</th></tr>
  <tr><td>Beginning</td><td>Today, First, Let's begin with</td></tr>
  <tr><td>Adding information</td><td>Furthermore, Moreover, In addition, Also</td></tr>
  <tr><td>Giving examples</td><td>For example, For instance, Such as</td></tr>
  <tr><td>Contrast</td><td>However, On the other hand, Although</td></tr>
  <tr><td>Cause and effect</td><td>Because, Therefore, As a result, Consequently</td></tr>
  <tr><td>Conclusion</td><td>Finally, In conclusion, To sum up, Overall</td></tr>
  </table>
  <h4>Note-Taking by Ideas</h4>
  <p><em>"Technology has changed education. Students can learn online, communicate with teachers more easily, and access educational resources from anywhere."</em></p>
  <p>Good notes: <code>Technology → Education: online learning / easier communication / more resources</code></p>
  <h4>Listening Practice 1 — Exercise for Students</h4>
  <p>Regular exercise strengthens the heart and muscles, reduces stress, improves mental health, and helps academic performance through more energy and concentration. Recommendation: universities should provide more sports facilities.</p>
  <div class="example-box"><strong>Answers:</strong> Topic: exercise · Physical benefit: stronger muscles · Mental benefit: reduced stress · Better academically because of more energy · Recommendation: more sports facilities.</div>
  <h4>Listening Practice 2 — Online Learning</h4>
  <p>Advantages: flexibility, access from anywhere. Problem: some students feel isolated / lack motivation. Recommendation (signalled by "Therefore"): combine online and classroom learning.</p>
  <h4>Main Idea vs Supporting Detail</h4>
  <p><strong>Main idea:</strong> the central message (e.g. "Exercise benefits university students"). <strong>Supporting details:</strong> facts, examples, statistics, explanations (better health, less stress, more energy, better academic performance).</p>
  <h4>Homework</h4><ul>
  <li>Learn 15 lecture vocabulary words with meanings and sentences.</li>
  <li>Watch/listen to a 5-minute educational lecture; note the topic, three main ideas, five supporting details, three signal words, and a one-sentence summary.</li>
  <li>Note-taking practice organised into a clear outline.</li>
  <li>Prepare and deliver a 2-minute mini-lecture with a clear introduction, two supporting points, ≥5 signal words, and a strong conclusion.</li>
  </ul>
  <div class="example-box"><strong>Key Takeaway:</strong> Signal words reveal a lecture's organisation — use them to separate the main idea from supporting details and to predict where the conclusion/recommendation will appear.</div>
  </div>`,
  quiz:[
    {q:"Which part usually comes first in a lecture?",opts:["Conclusion","Introduction","Example","Recommendation"],a:1},
    {q:"Which phrase introduces an example?",opts:["Therefore","For example","Finally","However"],a:1},
    {q:"Which word signals contrast?",opts:["However","Also","Therefore","Moreover"],a:0},
    {q:"The main idea of a lecture is:",opts:["A small supporting detail","The central message","One example","A statistic"],a:1}
  ]
},
{
  unit:"Module 2 — Listening Mastery",
  id:"8",
  title:"Listening Mock Test & Error Analysis",
  objectives:[
    "Complete a full CET-4-style listening test.",
    "Apply prediction and note-taking strategies.",
    "Recognise common distractors.",
    "Analyse mistakes systematically.",
    "Develop a personal improvement plan."
  ],
  success:[
    "Complete all three listening sections (news, long conversation, lecture) under timed conditions.",
    "Self-score using the CET-4 band table.",
    "Identify the cause of each wrong answer (keyword miss, number confusion, distractor, vocabulary gap, concentration).",
    "State one concrete improvement strategy per weak area.",
    "Write a reflective listening journal entry."
  ],
  vocab:[
    ["headline","标题"],["broadcast","广播；播出"],["witness","目击者"],["investigation","调查"],["rescue","救援"],
    ["appointment","预约"],["deadline","截止日期"],["scholarship","奖学金"],["postpone","推迟"],["available","有空的；可获得的"],
    ["lecture","讲座"],["evidence","证据"],["conclusion","结论"],["trend","趋势"],["recommendation","建议"]
  ],
  html:`
  <div class="content-body">
  <p><strong>Duration:</strong> 90 minutes &nbsp;|&nbsp; <strong>Target CET-4 Skills:</strong> Short News Reports, Long Conversations, Academic Lecture, Note-taking, Time Management, Error Analysis</p>
  <h4>Before You Begin</h4><ul>
  <li>Read the questions before each recording.</li>
  <li>Don't panic if you miss one word — listen for the main idea first.</li>
  <li>Pay attention to numbers, dates, places, opinions, and changes.</li>
  <li>Choose the final/corrected answer, not the first one mentioned.</li>
  </ul>
  <h4>Part A — Short News Reports</h4>
  <p><strong>Report 1:</strong> A new public library (300,000+ books, free digital resources) opens next month in the eastern district, to encourage reading. <strong>Report 2:</strong> A new butterfly species discovered in mountain forests above 2,000 metres in southwest China, raising awareness of wildlife protection.</p>
  <h4>Part B — Long Conversation</h4>
  <p>Emma is preparing an English presentation; she still needs to add charts and examples and is worried about pronunciation. She and the man agree to meet in the library tomorrow afternoon at three o'clock.</p>
  <h4>Part C — Academic Lecture</h4>
  <p>Topic: time management for university students. The real problem is often poor planning, not lack of time. Weekly schedules and hourly breaks improve productivity and concentration; students should set realistic goals and avoid distractions such as social media.</p>
  <h4>Self-Scoring</h4>
  <table class="data-table"><tr><th>Score (out of 16)</th><th>Level</th></tr>
  <tr><td>15–16</td><td>Excellent</td></tr><tr><td>13–14</td><td>Very Good</td></tr>
  <tr><td>10–12</td><td>Good</td></tr><tr><td>7–9</td><td>Developing</td></tr><tr><td>Below 7</td><td>Needs Improvement</td></tr>
  </table>
  <h4>Error Analysis Workshop</h4>
  <p>For every wrong answer, record: Was it a missed keyword? Number confusion? A distractor? A vocabulary gap? Lost concentration? — and pair each cause with a concrete strategy (e.g. "Distractor → listen until the end").</p>
  <h4>Five Golden Rules for CET-4 Listening</h4><ol>
  <li>Predict before listening — always read the questions first.</li>
  <li>Listen for keywords; ignore unnecessary details.</li>
  <li>Watch for changes: but, however, instead, finally, actually.</li>
  <li>Take short notes using symbols, never full sentences.</li>
  <li>Stay calm — missing one answer does not affect the rest of the recording. Move on quickly.</li>
  </ol>
  <h4>Homework</h4><ul>
  <li>Listen to three English news reports; log topic, main idea, three details, and new vocabulary for each.</li>
  <li>Review all vocabulary from Lessons 5–8; make 20 flashcards grouped by theme.</li>
  <li>Dictation practice on a short academic paragraph, checking spelling/capitals/punctuation.</li>
  <li>Write a 150-word listening reflection journal: strongest skill, biggest challenge, three strategies for next time, and one listening goal for the month.</li>
  </ul>
  <div class="example-box"><strong>Module 2 Learning Outcomes:</strong> You can now predict topics, identify keywords and distractors, follow short news reports and long conversations, recognise speaker attitude, take organised lecture notes, and evaluate your own listening performance.</div>
  </div>`,
  quiz:[
    {q:"On this mock test, how many total questions are there?",opts:["10","16","20","25"],a:1},
    {q:"A score of 13–14 out of 16 is rated:",opts:["Good","Very Good","Excellent","Developing"],a:1},
    {q:"If you miss one listening question, you should:",opts:["Stop and worry about it","Move on quickly","Replay the recording","Skip the next question too"],a:1},
    {q:"Which is NOT one of the Five Golden Rules?",opts:["Predict before listening","Write full sentences","Watch for signal words","Stay calm"],a:1}
  ]
}
];
CET4_DATA_EOF

# 2. New page: courses/cet4.html
mkdir -p courses
cat > courses/cet4.html <<'CET4_HTML_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CET-4 Master Course — Bored Academy</title>
<link rel="icon" href="../favicon.ico">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/theme.js"></script>
</head>
<body>
<button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()"></button>
<div class="sidebar-scrim" id="scrim" onclick="toggleSidebar()"></div>
<div class="app">
  <aside class="sidebar" id="sidebar"></aside>
  <main id="main"></main>
  <aside class="study-panel" id="studyPanel"></aside>
</div>

<nav class="bottom-nav">
  <button data-tab="home" onclick="bottomNavAction('home')"><span class="bn-icon"></span>Home</button>
  <button data-tab="lessons" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>Lessons</button>
  <button data-tab="quiz" onclick="bottomNavAction('quiz')"><span class="bn-icon"></span>Quiz</button>
  <button data-tab="progress" onclick="bottomNavAction('progress')"><span class="bn-icon"></span>Progress</button>
  <button data-tab="more" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>More</button>
</nav>

<script>
  window.COURSE_ID = "cet4";
  window.COURSE_META = { eyebrow: "Exam Prep", title: "CET-4 Master Course" };
</script>
<script src="../assets/js/icons.js"></script>
<script src="../assets/js/data/cet4-data.js"></script>
<script src="../assets/js/progress-store.js"></script>
<script src="../assets/js/course-app.js"></script>
<script>
  document.getElementById('sidebarToggle').innerHTML = icon('menu');
  document.querySelectorAll('.bottom-nav .bn-icon').forEach((el, i)=>{
    const map = ['home','book-open','help-circle','trending-up','more-horizontal'];
    el.innerHTML = icon(map[i]);
  });
</script>
</body>
</html>
CET4_HTML_EOF

# 3. Register the course on the hub: assets/js/data/courses.js
cat > assets/js/data/courses.js <<'COURSES_EOF'
// Master list of courses on offer. Each course with `available:true` and a
// `url` links to its own course page under /courses/. Courses without a url
// render as "Coming Soon" cards on the hub.
window.COURSES = [
  {
    id: "chemistry",
    icon: "🧪",
    title: "Introduction to Chemistry",
    blurb: "Matter, atomic structure, states of matter and lab safety.",
    lessons: 20,
    available: true,
    url: "courses/chemistry.html"
  },
  {
    id: "ielts",
    icon: "🗣️",
    title: "IELTS Speaking (Band 5.5 → 7.5)",
    blurb: "Fluency formulas, vocabulary upgrades, grammar and Part 2 cue-card strategy.",
    lessons: 10,
    available: true,
    url: "courses/ielts.html"
  },
  {
    id: "cet4",
    icon: "📝",
    title: "CET-4 Master Course",
    blurb: "12-week exam prep: grammar, listening, reading, writing and translation for the CET-4.",
    lessons: 8,
    available: true,
    url: "courses/cet4.html"
  },
  {
    id: "physics",
    icon: "⚡",
    title: "Physics",
    blurb: "Forces, motion, energy and electricity.",
    lessons: 0,
    available: false
  },
  {
    id: "maths",
    icon: "📐",
    title: "Mathematics",
    blurb: "Algebra, geometry, statistics and problem solving.",
    lessons: 0,
    available: false
  },
  {
    id: "geography",
    icon: "🌍",
    title: "Geography",
    blurb: "Maps, climate, ecosystems and human geography.",
    lessons: 0,
    available: false
  },
  {
    id: "computer-science",
    icon: "💻",
    title: "Computer Science",
    blurb: "Algorithms, data structures and programming fundamentals.",
    lessons: 0,
    available: false
  }
];
COURSES_EOF

# 4. Add sidebar unit icons: assets/js/course-app.js
cat > assets/js/course-app.js <<'APP_EOF'
const DATA = window.COURSE_DATA;
const COURSE_ID = window.COURSE_ID || 'course';
const PROGRESS_KEY = `boredacademy:progress:${COURSE_ID}`;

let current = 0;
let searchTerm = '';
const quizState = {}; // id -> {answered:[]}
DATA.forEach(l => quizState[l.id] = { answered: new Array(l.quiz.length).fill(null) });

(function loadProgress(){
  try{
    const saved = JSON.parse(localStorage.getItem(PROGRESS_KEY) || '{}');
    Object.keys(saved).forEach(id=>{
      if(quizState[id]) quizState[id].answered = saved[id];
    });
  }catch(e){ /* ignore corrupt/local-storage-unavailable state */ }
})();

function saveProgress(){
  try{
    const out = {};
    Object.keys(quizState).forEach(id => out[id] = quizState[id].answered);
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(out));
    const stats = totalStats();
    localStorage.setItem(`boredacademy:pct:${COURSE_ID}`, String(stats.pct));
  }catch(e){ /* storage unavailable — progress just won't persist */ }
}

const UNIT_ICONS = {
  "Unit 1 — Introduction to Chemistry":"🧪",
  "Unit 2 — States of Matter":"💧",
  "Unit 3 — Atomic Structure":"⚛️",
  "Module 1 — Building Fluency Foundations":"🗣️",
  "Module 2 — Expanding Your Vocabulary":"📚",
  "Module 3 — Mastering IELTS Speaking Part 2":"🎯",
  "Module 1 — Building the Foundation":"🧱",
  "Module 2 — Listening Mastery":"🎧"
};

function toggleSidebar(){
  document.getElementById('sidebar').classList.toggle('open');
  document.getElementById('scrim').classList.toggle('show');
}

function isLessonDone(l){
  const st = quizState[l.id];
  return st.answered.every(a=>a!==null) && st.answered.length>0;
}

function totalStats(){
  const totalQ = DATA.reduce((s,l)=>s+l.quiz.length,0);
  const answered = Object.values(quizState).reduce((s,st)=>s+st.answered.filter(a=>a!==null).length,0);
  const lessonsDone = DATA.filter(isLessonDone).length;
  return {totalQ, answered, lessonsDone, pct: Math.round((lessonsDone/DATA.length)*100)};
}

function renderSidebar(){
  const sb = document.getElementById('sidebar');
  const units = [...new Set(DATA.map(d=>d.unit))];
  const term = searchTerm.trim().toLowerCase();
  const meta = window.COURSE_META || {eyebrow:'Notebook', title:'Course'};
  let h = `<div class="brand"><div class="eyebrow">${meta.eyebrow}</div><h1>${meta.title}</h1></div>`;
  const stats = totalStats();
  h += `<div class="sidebar-progress"><span style="width:${stats.pct}%"></span></div>
        <div class="progress-note">${stats.pct}% COMPLETE · ${stats.answered}/${stats.totalQ} QUESTIONS ANSWERED</div>`;
  units.forEach(u=>{
    const lessonsInUnit = DATA.filter(l=>l.unit===u && (!term || l.title.toLowerCase().includes(term) || l.id.includes(term)));
    if(term && lessonsInUnit.length===0) return;
    h += `<div class="unit-group"><div class="unit-label">${UNIT_ICONS[u]||'📘'} <span class="label-text">${u}</span></div>`;
    DATA.forEach((l,i)=>{
      if(l.unit!==u) return;
      if(term && !(l.title.toLowerCase().includes(term) || l.id.includes(term))) return;
      const done = isLessonDone(l);
      h += `<button class="lesson-btn ${i===current?'active':''}" onclick="goTo(${i})">
              <span class="num">${l.id}</span><span class="lesson-title-text">${l.title}</span>
              <span class="lesson-dot ${done?'done':''}"></span>
            </button>`;
    });
    h += `</div>`;
  });
  sb.innerHTML = h;
}

function goTo(i){
  current = i; render(); window.scrollTo(0,0);
  document.getElementById('sidebar').classList.remove('open');
  document.getElementById('scrim').classList.remove('show');
  const l = DATA[i];
  if(window.ProgressStore){
    ProgressStore.setLastLesson(COURSE_ID, { lessonId: l.id, lessonTitle: l.title, unit: l.unit, index: i, courseTitle: (window.COURSE_META||{}).title || COURSE_ID });
  }
}

function toggleFlash(el){ el.classList.toggle('flipped'); }

function onSearch(v){ searchTerm = v; renderSidebar(); }

function estimateMinutes(l){
  const words = l.html.replace(/<[^>]+>/g,' ').split(/\s+/).length;
  return Math.max(8, Math.round(words/140) + l.quiz.length*2);
}

function renderMain(){
  const l = DATA[current];
  const m = document.getElementById('main');
  const st = quizState[l.id];

  let vocabHtml = l.vocab.map(([term,def])=>`
    <div class="flash" onclick="toggleFlash(this)">
      <div class="flash-inner">
        <div class="flash-face flash-front">${term}<span class="hint">tap to reveal</span></div>
        <div class="flash-face flash-back">${def}</div>
      </div>
    </div>`).join('');

  let quizHtml = l.quiz.map((q,qi)=>{
    const chosen = st.answered[qi];
    let opts = q.opts.map((o,oi)=>{
      let cls='quiz-opt';
      if(chosen!==null){
        if(oi===q.a) cls+=' correct';
        else if(oi===chosen) cls+=' incorrect';
      }
      return `<button class="${cls}" ${chosen!==null?'disabled':''} onclick="answer('${l.id}',${qi},${oi})">${o}</button>`;
    }).join('');
    return `<div class="quiz-q"><div class="qtext">${qi+1}. ${q.q}</div>${opts}</div>`;
  }).join('');

  const scored = st.answered.filter(a=>a!==null).length;
  const correct = st.answered.filter((a,i)=>a===l.quiz[i].a).length;
  const stats = totalStats();
  const mins = estimateMinutes(l);

  m.innerHTML = `
    <div class="topbar">
      <div class="topbar-search">🔍 <input placeholder="Search lessons..." value="${searchTerm}" oninput="onSearch(this.value)"></div>
      <div class="topbar-stats">
        <span>Progress <span class="stat-num">${stats.pct}%</span></span>
        <span class="topbar-pill">📚 ${DATA.length} lessons</span>
        <span class="topbar-pill">✅ ${stats.lessonsDone} done</span>
      </div>
    </div>

    <div class="lesson-head">
      <div class="eyebrow">${l.unit} · Lesson ${l.id}</div>
      <h2>${l.title}</h2>
      <div class="lesson-meta">
        <span class="m-item">⏱ <b>${mins} min</b></span>
        <span class="m-item">🧪 <b>${l.vocab.length}</b> key terms</span>
        <span class="m-item">❓ <b>${l.quiz.length}</b> questions</span>
        <span class="m-item">🎯 <b>${l.objectives.length}</b> objectives</span>
      </div>
    </div>

    <section class="block">
      <h3 class="block-title">Learning Objectives</h3>
      <ul class="obj-list">${l.objectives.map(o=>`<li>${o}</li>`).join('')}</ul>
    </section>

    <section class="block">
      <h3 class="block-title">Success Criteria</h3>
      <div class="success-box">${l.success.map(s=>`<div class="row"><span class="tick">✓</span>${s}</div>`).join('')}</div>
    </section>

    <section class="block">
      <h3 class="block-title">Key Vocabulary <span style="font-size:.6em;color:#888;font-weight:normal;">(tap to flip)</span></h3>
      <div class="vocab-grid">${vocabHtml}</div>
    </section>

    <section class="block">
      <h3 class="block-title">Lesson Notes</h3>
      ${l.html}
    </section>

    <section class="block quiz-section" id="quizSection">
      <h3 class="block-title">Check Your Understanding</h3>
      ${quizHtml}
    </section>

    <div class="nav-footer">
      <button ${current===0?'disabled':''} onclick="goTo(${current-1})">← Previous lesson</button>
      <button ${current===DATA.length-1?'disabled':''} onclick="goTo(${current+1})">Next lesson →</button>
    </div>

    ${scored>0 ? `
    <div class="floating-score">
      <div class="fs-top">
        <span class="fs-pct">${Math.round((correct/scored)*100)}%</span>
        <span class="fs-label">${correct===scored?'EXCELLENT':correct/scored>=0.6?'GOOD JOB':'KEEP GOING'}</span>
      </div>
      <div class="fs-bar"><span style="width:${(scored/l.quiz.length)*100}%"></span></div>
      <div class="fs-sub">
        <span>${correct} / ${l.quiz.length} correct</span>
        <button class="reset-btn" onclick="resetQuiz('${l.id}')">Reset</button>
      </div>
    </div>` : ''}
  `;
}

function answer(id, qi, oi){
  quizState[id].answered[qi] = oi;
  saveProgress();
  const l = DATA.find(x=>x.id===id);
  const q = l.quiz[qi];
  if(window.ProgressStore){
    const allAnswered = quizState[id].answered.every(a=>a!==null);
    if(allAnswered){
      const correct = quizState[id].answered.filter((a,idx)=>a===l.quiz[idx].a).length;
      const pct = Math.round((correct/l.quiz.length)*100);
      ProgressStore.logActivity({ type:'quiz', text:`${l.title} Quiz`, detail:`${pct}%`, courseId: COURSE_ID });
    }
  }
  render();
}
function resetQuiz(id){
  quizState[id].answered = new Array(DATA.find(l=>l.id===id).quiz.length).fill(null);
  saveProgress();
  render();
}

function renderStudyPanel(){
  const panel = document.getElementById('studyPanel');
  if(!panel) return;
  const l = DATA[current];
  const st = quizState[l.id];
  const answeredCount = st.answered.filter(a=>a!==null).length;
  panel.innerHTML = `
    <h3>On This Page</h3>
    <ul>${l.objectives.slice(0,4).map(o=>`<li>${o}</li>`).join('')}</ul>
    <h3>Key Vocabulary</h3>
    ${l.vocab.slice(0,6).map(([t,d])=>`<div class="sp-vocab"><b>${t}</b><span>${d.length>46?d.slice(0,46)+'…':d}</span></div>`).join('')}
    <h3>Quick Quiz</h3>
    <div class="sp-quiz-mini">${answeredCount}/${l.quiz.length} questions answered in this lesson.</div>
  `;
}

function setBottomNavActive(tab){
  document.querySelectorAll('.bottom-nav button').forEach(b=>b.classList.toggle('active', b.dataset.tab===tab));
}

function bottomNavAction(tab){
  setBottomNavActive(tab);
  if(tab==='home'){ window.location.href = '../index.html'; return; }
  if(tab==='lessons'){ toggleSidebar(); return; }
  if(tab==='quiz'){
    document.querySelector('.quiz-section')?.scrollIntoView({behavior:'smooth'});
    return;
  }
  if(tab==='progress'){
    document.querySelector('.floating-score')?.scrollIntoView({behavior:'smooth'});
    return;
  }
}

function render(){
  renderSidebar();
  renderMain();
  renderStudyPanel();
  setBottomNavActive('lessons');
}
if(window.ProgressStore){
  ProgressStore.recordVisitToday();
  if(!ProgressStore.getLastLesson(COURSE_ID) && DATA[current]){
    const l = DATA[current];
    ProgressStore.setLastLesson(COURSE_ID, { lessonId: l.id, lessonTitle: l.title, unit: l.unit, index: current, courseTitle: (window.COURSE_META||{}).title || COURSE_ID });
  }
}
render();
APP_EOF

echo "Done. New/updated files:"
echo "  assets/js/data/cet4-data.js"
echo "  courses/cet4.html"
echo "  assets/js/data/courses.js (added CET-4 entry)"
echo "  assets/js/course-app.js (added Module 1/2 sidebar icons)"
echo "Open index.html or courses/cet4.html in a browser to verify."
