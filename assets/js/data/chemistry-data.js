window.COURSE_DATA = [
{
  unit:"Unit 1 — Introduction to Chemistry",
  id:"1.1",
  title:"What is Chemistry?",
  objectives:[
    "Define chemistry.",
    "Explain why chemistry is important.",
    "Identify examples of chemistry in everyday life.",
    "Distinguish between natural and synthetic substances.",
    "Recognize different branches of chemistry."
  ],
  success:[
    "Define chemistry.",
    "Give examples of chemistry in everyday life.",
    "Name the five main branches of chemistry.",
    "Explain why chemistry is important to society."
  ],
  vocab:[
    ["Chemistry","The study of matter and the changes it undergoes."],
    ["Matter","Anything that has mass and occupies space."],
    ["Atom","The smallest particle of an element."],
    ["Molecule","Two or more atoms chemically bonded together."],
    ["Substance","A material with a fixed composition."],
    ["Reaction","A process in which substances change into new substances."],
    ["Element","A pure substance made of one type of atom."],
    ["Compound","A substance made from two or more elements chemically joined together."]
  ],
  html:`
  <div class="content-body">
  <p><strong>Chemistry</strong> is the study of matter and the changes that matter undergoes. Matter is everything around us — anything you can touch, smell, taste, or breathe. Chemistry helps us understand what things are made of, how they are formed, how they react, and how they change into new substances.</p>

  <h4>Why is chemistry important?</h4>
  <ul>
    <li><strong>Medicine</strong> — antibiotics, vaccines, painkillers.</li>
    <li><strong>Food</strong> — fertilizers, preservatives, flavourings, vitamins.</li>
    <li><strong>Energy</strong> — batteries, petrol, solar cells, hydrogen fuel.</li>
    <li><strong>Clothing</strong> — nylon, polyester, rayon.</li>
    <li><strong>Construction</strong> — cement, steel, glass, paint.</li>
    <li><strong>Technology</strong> — mobile phones, computer chips, LEDs, lithium batteries.</li>
  </ul>

  <h4>The five main branches of chemistry</h4>
  <table class="data-table">
    <tr><th>Branch</th><th>Focus</th><th>Examples</th></tr>
    <tr><td>Organic Chemistry</td><td>Carbon compounds</td><td>Petrol, plastic, medicines, sugar</td></tr>
    <tr><td>Inorganic Chemistry</td><td>Non-carbon-based substances</td><td>Salt, iron, water, acids</td></tr>
    <tr><td>Physical Chemistry</td><td>How and why reactions happen</td><td>Energy, reaction rates, heat</td></tr>
    <tr><td>Analytical Chemistry</td><td>Identifying what substances contain</td><td>Blood tests, water testing, food testing</td></tr>
    <tr><td>Biochemistry</td><td>Chemistry of living things</td><td>DNA, proteins, enzymes</td></tr>
  </table>

  <div class="example-box"><strong>Think like a chemist — a candle:</strong> before lighting, wax is solid. When lit, wax melts, evaporates, and burns, producing heat, light, and new substances (carbon dioxide and water vapor). A chemist asks: why does this happen? What new substances are made? Can we measure the energy released?</div>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Chemistry is only done in laboratories.</div>
    <div class="row right">Correct: Chemistry happens everywhere.</div>
    <div class="row wrong">Incorrect: Chemicals are always dangerous.</div>
    <div class="row right">Correct: Everything is made of chemicals, including water and oxygen.</div>
    <div class="row wrong">Incorrect: Natural substances are always safe.</div>
    <div class="row right">Correct: Some natural substances, such as poisonous mushrooms or snake venom, can be very dangerous.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Chemistry is the study of:",opts:["Animals","Plants","Matter and its changes","Space"],a:2},
    {q:"Which of these is made of matter?",opts:["Air","Water","Chair","All of the above"],a:3},
    {q:"Which branch studies living organisms?",opts:["Organic Chemistry","Analytical Chemistry","Biochemistry","Physical Chemistry"],a:2},
    {q:"Which branch studies carbon compounds?",opts:["Inorganic Chemistry","Organic Chemistry","Analytical Chemistry","Physical Chemistry"],a:1}
  ]
},
{
  unit:"Unit 1 — Introduction to Chemistry",
  id:"1.2",
  title:"Laboratory Safety",
  objectives:[
    "Explain why laboratory safety is important.",
    "Identify common laboratory hazards.",
    "Recognize standard laboratory safety symbols.",
    "Use laboratory equipment safely.",
    "Describe the correct response to common laboratory accidents."
  ],
  success:[
    "Explain why laboratory rules are important.",
    "Identify common laboratory hazards.",
    "Recognize laboratory safety symbols.",
    "Follow safe laboratory procedures."
  ],
  vocab:[
    ["Hazard","Something that can cause harm."],
    ["Risk","The chance that a hazard will cause harm."],
    ["Safety Goggles","Protective eyewear used in laboratories."],
    ["Lab Coat","Protective clothing worn during experiments."],
    ["Corrosive","A substance that can burn skin or damage materials."],
    ["Flammable","A substance that catches fire easily."],
    ["Toxic","Poisonous if swallowed, inhaled, or absorbed through the skin."],
    ["Emergency","A dangerous situation requiring immediate action."]
  ],
  html:`
  <div class="content-body">
  <p>Chemistry experiments often involve heat, glass equipment, electricity, chemicals, and gases — all of which can be dangerous if not handled properly. Following safety rules helps prevent burns, cuts, poisoning, fires, eye injuries, and chemical spills.</p>

  <h4>Personal protective equipment (PPE)</h4>
  <ul>
    <li><strong>Safety goggles</strong> — protect eyes from chemical splashes, broken glass, flying particles.</li>
    <li><strong>Lab coat</strong> — protects clothes and skin.</li>
    <li><strong>Gloves</strong> — protect hands from corrosive chemicals and hot materials.</li>
    <li><strong>Closed-toe shoes</strong> — protect feet from broken glass and chemical spills.</li>
  </ul>

  <h4>General rules</h4>
  <p><strong>Always:</strong> listen to your teacher, read instructions first, wear safety goggles, tie back long hair, keep your area tidy, wash hands after experiments, report accidents immediately.</p>
  <p><strong>Never:</strong> eat or drink, taste chemicals, smell chemicals directly, run, play jokes, mix chemicals without permission.</p>

  <div class="example-box"><strong>Wafting technique</strong> for smelling chemicals: hold the container away from your face and gently wave the air above it toward your nose with your hand — never smell a chemical directly.</div>

  <h4>Safety symbols</h4>
  <table class="data-table">
    <tr><th>Symbol</th><th>Meaning</th></tr>
    <tr><td><strong>FL</strong></td><td>Flammable</td></tr>
    <tr><td><strong>TOX</strong></td><td>Toxic</td></tr>
    <tr><td><strong>COR</strong></td><td>Corrosive</td></tr>
    <tr><td><strong>EXP</strong></td><td>Explosive</td></tr>
    <tr><td><strong>IRR</strong></td><td>Irritant / Harmful</td></tr>
    <tr><td><strong>ENV</strong></td><td>Environmental Hazard</td></tr>
    <tr><td><strong>OX</strong></td><td>Oxidizing</td></tr>
    <tr><td><strong>HH</strong></td><td>Health Hazard</td></tr>
  </table>

  <h4>What to do in an emergency</h4>
  <ul>
    <li><strong>Chemical on skin</strong> — wash immediately with plenty of water; inform the teacher.</li>
    <li><strong>Chemical in eyes</strong> — rinse with clean running water for at least 15 minutes; tell the teacher immediately.</li>
    <li><strong>Small fire</strong> — turn off the gas supply; use the correct fire extinguisher or fire blanket.</li>
    <li><strong>Broken glass</strong> — do not pick it up with your hands; use a brush and dustpan if instructed.</li>
    <li><strong>Chemical spill</strong> — keep away and report it; do not attempt to clean it without permission.</li>
  </ul>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Smelling chemicals directly.</div>
    <div class="row right">Correct: Use the wafting method.</div>
    <div class="row wrong">Incorrect: Leaving a flame unattended.</div>
    <div class="row right">Correct: Turn off the burner when not in use.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Why should safety goggles be worn?",opts:["To keep your hair tidy","To protect your eyes from chemical splashes","To improve your eyesight","To keep chemicals warm"],a:1},
    {q:"Which action is safe in a laboratory?",opts:["Eating snacks","Running between benches","Wearing closed-toe shoes","Tasting chemicals"],a:2},
    {q:"Which symbol indicates a flammable substance?",opts:["Skull and crossbones","Flame","Tree and fish","Test tube on hand"],a:1},
    {q:"What should you do if a chemical gets into your eyes?",opts:["Wait and see if it stings","Rinse with running water for at least 15 minutes","Rub your eyes","Cover your eyes and continue working"],a:1}
  ]
},
{
  unit:"Unit 1 — Introduction to Chemistry",
  id:"1.3",
  title:"The Scientific Method",
  objectives:[
    "Define the scientific method.",
    "Describe each step of a scientific investigation.",
    "Identify variables in an experiment.",
    "Explain the importance of fair testing.",
    "Record observations and draw evidence-based conclusions."
  ],
  success:[
    "Explain the steps of the scientific method.",
    "Identify independent, dependent, and control variables.",
    "Describe how to carry out a fair test.",
    "Write a conclusion based on evidence."
  ],
  vocab:[
    ["Observation","Information gathered using the senses or measuring equipment."],
    ["Hypothesis","A prediction that can be tested by an experiment."],
    ["Experiment","A scientific test carried out to investigate a question."],
    ["Variable","A factor that can change during an experiment."],
    ["Independent Variable","The variable that is deliberately changed."],
    ["Dependent Variable","The variable that is measured or observed."],
    ["Control Variable","A variable that is kept the same to ensure a fair test."],
    ["Conclusion","A statement explaining what the results show."],
    ["Fair Test","An investigation where only one variable is changed at a time."]
  ],
  html:`
  <div class="content-body">
  <p>The <strong>scientific method</strong> is a step-by-step process used to answer questions and solve problems through investigation, helping scientists produce reliable and repeatable results.</p>

  <h4>The steps</h4>
  <ol>
    <li><strong>Ask a question</strong> — clear, specific, and testable.</li>
    <li><strong>Research</strong> — gather information from reliable sources.</li>
    <li><strong>Form a hypothesis</strong> — an educated prediction, often "If... then... because...".</li>
    <li><strong>Plan and carry out an experiment</strong> — follow a clear, fair method.</li>
    <li><strong>Record observations and results</strong> — qualitative (descriptive) and quantitative (numerical) data.</li>
    <li><strong>Analyse the results</strong> — look for patterns; consider errors.</li>
    <li><strong>Draw a conclusion</strong> — answer the question using evidence; state whether the hypothesis was supported.</li>
    <li><strong>Evaluate the investigation</strong> — consider accuracy, sources of error, and improvements.</li>
  </ol>

  <h4>Variables</h4>
  <table class="data-table">
    <tr><th>Variable Type</th><th>Definition</th><th>Example</th></tr>
    <tr><td>Independent</td><td>The factor changed on purpose</td><td>Water temperature</td></tr>
    <tr><td>Dependent</td><td>The factor that is measured</td><td>Time for sugar to dissolve</td></tr>
    <tr><td>Control</td><td>Factors kept the same</td><td>Amount of sugar, volume of water, stirring method</td></tr>
  </table>

  <div class="example-box"><strong>Example hypothesis:</strong> If the temperature of the water increases, then sugar will dissolve faster, because the water particles move more quickly.</div>

  <p>A <strong>fair test</strong> ensures that any change in the results is caused only by the independent variable — changing more than one variable at a time makes it impossible to know what caused the results.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Changing more than one variable.</div>
    <div class="row right">Correct: Change only the independent variable.</div>
    <div class="row wrong">Incorrect: Writing a hypothesis as a fact.</div>
    <div class="row right">Correct: Write it as a prediction.</div>
    <div class="row wrong">Incorrect: Drawing conclusions without evidence.</div>
    <div class="row right">Correct: Base conclusions on the results collected.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which step comes after forming a hypothesis?",opts:["Draw a conclusion","Carry out an experiment","Ask a question","Analyse results"],a:1},
    {q:"Which variable is deliberately changed?",opts:["Control variable","Dependent variable","Independent variable","Constant"],a:2},
    {q:"Why are control variables important?",opts:["They make the experiment faster","They ensure the test is fair","They change during the experiment","They replace the dependent variable"],a:1},
    {q:"In an investigation into plant growth and light, what is the dependent variable?",opts:["Amount of light","Height of the plant","Type of soil","Pot size"],a:1}
  ]
},
{
  unit:"Unit 1 — Introduction to Chemistry",
  id:"1.4",
  title:"Measurements and SI Units",
  objectives:[
    "Explain why accurate measurement is important in chemistry.",
    "Identify the seven SI base units.",
    "Use common laboratory measuring instruments correctly.",
    "Measure length, mass, volume, temperature, and time using appropriate units.",
    "Convert between common metric units."
  ],
  success:[
    "State the SI base units used in science.",
    "Choose the correct measuring instrument for different quantities.",
    "Measure quantities accurately.",
    "Convert between metric units."
  ],
  vocab:[
    ["Measurement","The process of determining the size, amount, or quantity of something."],
    ["SI Units","The International System of Units used worldwide in science."],
    ["Mass","The amount of matter in an object."],
    ["Volume","The amount of space occupied by a substance."],
    ["Temperature","A measure of how hot or cold something is."],
    ["Meniscus","The curved surface of a liquid in a measuring cylinder."],
    ["Balance","An instrument used to measure mass."],
    ["Thermometer","An instrument used to measure temperature."]
  ],
  html:`
  <div class="content-body">
  <p>Chemists rely on accurate measurements to carry out fair experiments, produce reliable results, ensure safety, compare results with other scientists, and manufacture medicines and chemicals correctly. Even a small measurement error can affect an experiment's outcome.</p>

  <table class="data-table">
    <tr><th>Quantity</th><th>SI Unit</th><th>Symbol</th></tr>
    <tr><td>Length</td><td>metre</td><td>m</td></tr>
    <tr><td>Mass</td><td>kilogram</td><td>kg</td></tr>
    <tr><td>Time</td><td>second</td><td>s</td></tr>
    <tr><td>Temperature</td><td>kelvin</td><td>K</td></tr>
    <tr><td>Electric current</td><td>ampere</td><td>A</td></tr>
    <tr><td>Amount of substance</td><td>mole</td><td>mol</td></tr>
    <tr><td>Luminous intensity</td><td>candela</td><td>cd</td></tr>
  </table>
  <p><em>Note: in school labs, temperature is usually measured in degrees Celsius (°C), even though the SI base unit is the kelvin (K).</em></p>

  <h4>Choosing the correct instrument</h4>
  <table class="data-table">
    <tr><th>Quantity</th><th>Instrument</th></tr>
    <tr><td>Length</td><td>Ruler</td></tr>
    <tr><td>Mass</td><td>Electronic balance</td></tr>
    <tr><td>Volume</td><td>Measuring cylinder</td></tr>
    <tr><td>Temperature</td><td>Thermometer</td></tr>
    <tr><td>Time</td><td>Stopwatch</td></tr>
  </table>

  <div class="example-box"><strong>Reading a meniscus:</strong> always read the bottom of the curved liquid surface at eye level to avoid parallax error. Example volume reading: <strong>42.5 mL</strong>.</div>

  <h4>Metric prefixes &amp; conversions</h4>
  <ul>
    <li>1 kg = 1000 g &nbsp;|&nbsp; 1 g = 1000 mg</li>
    <li>1 m = 100 cm &nbsp;|&nbsp; 1 cm = 10 mm</li>
    <li>1 L = 1000 mL &nbsp;|&nbsp; 1 cm³ = 1 mL</li>
  </ul>
  <div class="example-box">Convert 2500 g to kg → 2500 ÷ 1000 = <strong>2.5 kg</strong><br>Convert 4.2 L to mL → 4.2 × 1000 = <strong>4200 mL</strong><br>Convert 350 mm to cm → 350 ÷ 10 = <strong>35 cm</strong></div>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Reading the top of the meniscus.</div>
    <div class="row right">Correct: Read the bottom of the meniscus (for most liquids).</div>
    <div class="row wrong">Incorrect: Using the wrong instrument.</div>
    <div class="row right">Correct: Choose the instrument that provides the most suitable accuracy.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which instrument is used to measure mass?",opts:["Ruler","Thermometer","Electronic balance","Stopwatch"],a:2},
    {q:"Which SI unit is used for time?",opts:["Minute","Second","Hour","Day"],a:1},
    {q:"When reading a measuring cylinder, you should read the:",opts:["Top of the liquid","Bottom of the meniscus at eye level","Side of the cylinder","Middle of the liquid"],a:1},
    {q:"Convert 3.5 kg to grams:",opts:["35 g","350 g","3500 g","35000 g"],a:2},
    {q:"Convert 650 mL to litres:",opts:["0.65 L","6.5 L","65 L","0.065 L"],a:0}
  ]
},
{
  unit:"Unit 1 — Introduction to Chemistry",
  id:"1.5",
  title:"Accuracy, Precision, and Significant Figures",
  objectives:[
    "Define accuracy and precision.",
    "Distinguish between random and systematic errors.",
    "Explain the importance of repeat measurements.",
    "Record measurements using the correct number of significant figures.",
    "Round numbers correctly."
  ],
  success:[
    "Explain the difference between accuracy and precision.",
    "Identify different types of experimental errors.",
    "Use significant figures correctly.",
    "Record measurements appropriately."
  ],
  vocab:[
    ["Accuracy","How close a measurement is to the true or accepted value."],
    ["Precision","How close repeated measurements are to each other."],
    ["Random Error","An unpredictable error that causes measurements to vary."],
    ["Systematic Error","An error that consistently affects measurements in the same way."],
    ["Significant Figures","The meaningful digits in a measured value."],
    ["Mean","The average of a set of measurements."],
    ["Uncertainty","The range within which the true value is likely to lie."]
  ],
  html:`
  <div class="content-body">
  <p><strong>Accuracy</strong> describes how close a measurement is to the true or accepted value. <strong>Precision</strong> describes how close repeated measurements are to one another, regardless of whether they are close to the true value.</p>

  <table class="data-table">
    <tr><th>Situation</th><th>Accurate?</th><th>Precise?</th></tr>
    <tr><td>Close to true value and close together</td><td>Complete</td><td>Complete</td></tr>
    <tr><td>Close together but far from true value</td><td aria-label="No">—</td><td>Complete</td></tr>
    <tr><td>Close to true value but spread out</td><td>Complete</td><td aria-label="No">—</td></tr>
    <tr><td>Far from true value and spread out</td><td aria-label="No">—</td><td aria-label="No">—</td></tr>
  </table>

  <h4>Errors</h4>
  <p><strong>Random errors</strong> occur unpredictably (e.g. estimating the last digit on a scale). Reduce them by repeating measurements and calculating the mean. <strong>Systematic errors</strong> consistently affect measurements in the same direction (e.g. a balance that always reads +0.5 g). Reduce them by calibrating equipment.</p>

  <h4>Significant figures — rules</h4>
  <ul>
    <li>All non-zero digits are significant. (456 → 3 s.f.)</li>
    <li>Zeros between non-zero digits are significant. (3007 → 4 s.f.)</li>
    <li>Leading zeros are not significant. (0.0045 → 2 s.f.)</li>
    <li>Trailing zeros after a decimal point are significant. (2.300 → 4 s.f.)</li>
  </ul>
  <div class="example-box">Round 4.6789 to 3 s.f. → <strong>4.68</strong><br>Round 0.006482 to 2 s.f. → <strong>0.0065</strong><br>Round 3654 to 2 s.f. → <strong>3700</strong></div>

  <h4>Scientific notation</h4>
  <p>3 500 000 = 3.5 × 10⁶ &nbsp;&nbsp; 0.00042 = 4.2 × 10⁻⁴</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Confusing accuracy with precision.</div>
    <div class="row right">Correct: Accuracy = closeness to the true value; precision = closeness of repeated measurements.</div>
    <div class="row wrong">Incorrect: Counting leading zeros as significant figures.</div>
    <div class="row right">Correct: Leading zeros are placeholders and are not significant.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which statement describes accuracy?",opts:["Measurements close to each other","Measurements close to the true value","Measurements with many decimal places","Measurements made quickly"],a:1},
    {q:"Which error is caused by a faulty balance that always reads 0.5 g too high?",opts:["Random error","Human error","Systematic error","Calculation error"],a:2},
    {q:"How many significant figures are there in 0.00560?",opts:["2","3","4","5"],a:1},
    {q:"Round 7.8456 to 3 significant figures:",opts:["7.84","7.85","7.8","7.846"],a:1},
    {q:"Round 4568 to 2 significant figures:",opts:["4500","4600","4570","4600.0"],a:1}
  ]
},
{
  unit:"Unit 2 — States of Matter",
  id:"2.2",
  title:"Solids, Liquids and Gases",
  objectives:[
    "Describe the properties of solids, liquids, and gases.",
    "Compare the arrangement and movement of particles in each state.",
    "Explain the differences in shape, volume, and compressibility.",
    "Use the particle model to explain everyday observations."
  ],
  success:[
    "Describe the properties of solids, liquids, and gases.",
    "Explain how particles behave in each state.",
    "Compare the three states of matter.",
    "Give everyday examples of each state."
  ],
  vocab:[
    ["Solid","A state of matter with a fixed shape and fixed volume."],
    ["Liquid","A state of matter with a fixed volume but no fixed shape."],
    ["Gas","A state of matter with no fixed shape or volume."],
    ["Compressible","Able to be squeezed into a smaller volume."],
    ["Particle","A tiny piece of matter, such as an atom or molecule."],
    ["Force of Attraction","The force that pulls particles together."]
  ],
  html:`
  <div class="content-body">
  <p>The state a substance is in depends on how closely packed its particles are, how much energy they have, and the strength of the forces of attraction between them.</p>

  <table class="data-table">
    <tr><th>Property</th><th>Solid</th><th>Liquid</th><th>Gas</th></tr>
    <tr><td>Shape</td><td>Fixed</td><td>Takes shape of container</td><td>Fills container</td></tr>
    <tr><td>Volume</td><td>Fixed</td><td>Fixed</td><td>Not fixed</td></tr>
    <tr><td>Particle arrangement</td><td>Very close, regular</td><td>Close, irregular</td><td>Far apart</td></tr>
    <tr><td>Particle movement</td><td>Vibrate in place</td><td>Slide past each other</td><td>Move freely and rapidly</td></tr>
    <tr><td>Compressibility</td><td>Very low</td><td>Low</td><td>High</td></tr>
    <tr><td>Density</td><td>High</td><td>Medium</td><td>Low</td></tr>
  </table>

  <h4>Forces of attraction</h4>
  <p><strong>Solids</strong> — strong forces hold particles tightly together. <strong>Liquids</strong> — weaker forces allow particles to move past one another. <strong>Gases</strong> — very weak forces allow particles to spread out freely.</p>

  <div class="example-box"><strong>Why can you squeeze air into a bicycle pump?</strong> Air is a gas, so its particles are far apart and can be pushed closer together.<br><strong>Why does a brick keep its shape?</strong> A brick is a solid, so its particles are held in fixed positions by strong forces.</div>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Liquids have no volume.</div>
    <div class="row right">Correct: Liquids have a fixed volume but no fixed shape.</div>
    <div class="row wrong">Incorrect: Gases have no mass.</div>
    <div class="row right">Correct: Gases have mass and occupy space.</div>
    <div class="row wrong">Incorrect: Solid particles do not move.</div>
    <div class="row right">Correct: Solid particles vibrate about fixed positions.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which state of matter has a fixed shape and a fixed volume?",opts:["Gas","Liquid","Solid","Plasma"],a:2},
    {q:"Which state of matter is most easily compressed?",opts:["Solid","Liquid","Gas","Ice"],a:2},
    {q:"Why do liquids flow?",opts:["Their particles are fixed in place","Their particles are far apart","Their particles can slide past one another","They have no particles"],a:2},
    {q:"Why can gases be compressed more easily than liquids?",opts:["Gas particles are far apart with large spaces between them","Gas particles are heavier","Gas particles do not move","Liquids have no particles"],a:0}
  ]
},
{
  unit:"Unit 2 — States of Matter",
  id:"2.3",
  title:"Changes of State",
  objectives:[
    "Describe the different changes of state.",
    "Explain changes of state using the particle model.",
    "Define melting point and boiling point.",
    "Explain the effect of heating and cooling on particles.",
    "Identify physical changes in everyday life."
  ],
  success:[
    "Name the six changes of state.",
    "Explain what happens to particles during heating and cooling.",
    "Define melting point and boiling point.",
    "Identify whether a change of state is melting, freezing, boiling, condensation, evaporation, or sublimation."
  ],
  vocab:[
    ["Melting","The change from a solid to a liquid."],
    ["Freezing","The change from a liquid to a solid."],
    ["Boiling","The rapid change from a liquid to a gas throughout the liquid."],
    ["Evaporation","The slow change from a liquid to a gas at the surface of the liquid."],
    ["Condensation","The change from a gas to a liquid."],
    ["Sublimation","The direct change from a solid to a gas without becoming a liquid."],
    ["Melting Point","The temperature at which a solid melts."],
    ["Boiling Point","The temperature at which a liquid boils."]
  ],
  html:`
  <div class="content-body">
  <p>A <strong>change of state</strong> occurs when a substance changes between solid, liquid, and gas due to heating or cooling. No new substance is formed — it is a physical, not chemical, change. The particles remain the same; only their arrangement and movement change.</p>

  <table class="data-table">
    <tr><th>From</th><th>To</th><th>Change of State</th></tr>
    <tr><td>Solid</td><td>Liquid</td><td>Melting</td></tr>
    <tr><td>Liquid</td><td>Solid</td><td>Freezing</td></tr>
    <tr><td>Liquid</td><td>Gas</td><td>Boiling or Evaporation</td></tr>
    <tr><td>Gas</td><td>Liquid</td><td>Condensation</td></tr>
    <tr><td>Solid</td><td>Gas</td><td>Sublimation</td></tr>
    <tr><td>Gas</td><td>Solid</td><td>Deposition (extension)</td></tr>
  </table>

  <h4>Particle behaviour</h4>
  <table class="data-table">
    <tr><th>State</th><th>Particle Movement</th><th>Particle Arrangement</th></tr>
    <tr><td>Solid</td><td>Vibrate in place</td><td>Closely packed, regular</td></tr>
    <tr><td>Liquid</td><td>Slide past one another</td><td>Close together, irregular</td></tr>
    <tr><td>Gas</td><td>Move rapidly in all directions</td><td>Far apart</td></tr>
  </table>
  <p>Heating increases particle movement; cooling decreases it. The <strong>melting point</strong> is the temperature at which a solid becomes a liquid (e.g. ice melts at 0°C); the <strong>boiling point</strong> is the temperature at which a liquid becomes a gas throughout the liquid (e.g. water boils at 100°C). Each pure substance has its own characteristic melting and boiling point.</p>

  <h4>Evaporation vs boiling</h4>
  <table class="data-table">
    <tr><th>Evaporation</th><th>Boiling</th></tr>
    <tr><td>Occurs at any temperature</td><td>Occurs only at the boiling point</td></tr>
    <tr><td>Happens only at the surface</td><td>Happens throughout the liquid</td></tr>
    <tr><td>Slow process</td><td>Rapid process</td></tr>
  </table>

  <div class="example-box"><strong>Sublimation</strong> examples: dry ice (solid carbon dioxide), iodine crystals, some solid air fresheners — these change directly from solid to gas.</div>

  <p>During melting and boiling, temperature stays constant because the energy supplied overcomes the forces of attraction between particles rather than increasing their kinetic energy.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Boiling and evaporation are the same.</div>
    <div class="row right">Correct: Boiling occurs throughout the liquid at a fixed temperature; evaporation happens only at the surface at any temperature.</div>
    <div class="row wrong">Incorrect: Melting changes water into a new substance.</div>
    <div class="row right">Correct: Melted ice is still water (H₂O).</div>
    <div class="row wrong">Incorrect: All solids melt before becoming gases.</div>
    <div class="row right">Correct: Some solids, such as dry ice, sublime directly into gases.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which change of state occurs when a liquid becomes a gas throughout the liquid?",opts:["Condensation","Freezing","Boiling","Sublimation"],a:2},
    {q:"Which process occurs only at the surface of a liquid?",opts:["Boiling","Freezing","Evaporation","Melting"],a:2},
    {q:"Which of the following is an example of sublimation?",opts:["Ice melting","Water boiling","Dry ice changing directly into carbon dioxide gas","Steam becoming water"],a:2},
    {q:"Why does temperature stay constant during boiling?",opts:["The particles stop moving","Energy overcomes forces between particles instead of raising kinetic energy","The liquid has no more energy to absorb","Boiling only happens at low temperatures"],a:1}
  ]
},
{
  unit:"Unit 2 — States of Matter",
  id:"2.4",
  title:"Diffusion",
  objectives:[
    "Define diffusion.",
    "Explain diffusion using the particle model.",
    "Compare diffusion in gases and liquids.",
    "Describe factors that affect the rate of diffusion.",
    "Give everyday examples of diffusion."
  ],
  success:[
    "Define diffusion.",
    "Explain why diffusion occurs.",
    "Compare diffusion in gases and liquids.",
    "Describe how temperature affects the rate of diffusion."
  ],
  vocab:[
    ["Diffusion","The movement of particles from a region of higher concentration to a region of lower concentration."],
    ["Concentration","The amount of a substance in a given volume."],
    ["Concentration Gradient","The difference in concentration between two areas."],
    ["Random Motion","Continuous movement of particles in all directions."],
    ["Equilibrium","The state where particles are evenly distributed throughout a space."]
  ],
  html:`
  <div class="content-body">
  <p><strong>Diffusion</strong> is the net movement of particles from an area of high concentration to an area of low concentration. This movement continues until particles are evenly spread throughout the available space, and it occurs because particles are in constant random motion.</p>

  <h4>Diffusion in different states</h4>
  <table class="data-table">
    <tr><th>State</th><th>Speed</th><th>Reason</th></tr>
    <tr><td>Gas</td><td>Fast</td><td>Particles are far apart, move quickly, weak forces of attraction</td></tr>
    <tr><td>Liquid</td><td>Slower</td><td>Particles are closer together and move more slowly</td></tr>
    <tr><td>Solid</td><td>Extremely slow / negligible</td><td>Particles are tightly packed and only vibrate in place</td></tr>
  </table>
  <p>Overall rate: <strong>Gas &gt; Liquid &gt; Solid</strong>.</p>

  <h4>Factors affecting the rate of diffusion</h4>
  <ul>
    <li><strong>Temperature</strong> — higher temperature gives particles more kinetic energy, so diffusion is faster.</li>
    <li><strong>Concentration gradient</strong> — a bigger difference in concentration causes faster diffusion.</li>
    <li><strong>Size of particles</strong> — smaller particles diffuse more quickly than larger ones.</li>
    <li><strong>State of matter</strong> — gas particles have the most freedom of movement.</li>
  </ul>

  <div class="example-box">Everyday examples: perfume spreading through a room, a tea bag colouring hot water, oxygen diffusing from lungs into blood while carbon dioxide diffuses the other way.</div>

  <p>At <strong>equilibrium</strong>, particles are evenly distributed — they are still moving randomly, but there is no further net movement.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Diffusion only happens in gases.</div>
    <div class="row right">Correct: Diffusion occurs in gases, liquids, and solids, but is much slower in solids.</div>
    <div class="row wrong">Incorrect: Particles stop moving at equilibrium.</div>
    <div class="row right">Correct: Particles keep moving randomly; only the net movement stops.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Diffusion is the movement of particles from:",opts:["Low concentration to high concentration","High concentration to low concentration","Hot regions to cold regions only","Heavy particles to light particles"],a:1},
    {q:"In which state does diffusion occur the fastest?",opts:["Solid","Liquid","Gas","Plasma"],a:2},
    {q:"Which factor increases the rate of diffusion?",opts:["Lower temperature","Smaller concentration gradient","Higher temperature","Larger particle size"],a:2},
    {q:"What happens to particles at equilibrium?",opts:["They stop moving completely","They continue moving randomly with no net movement","They only move in one direction","They freeze in place"],a:1}
  ]
},
{
  unit:"Unit 2 — States of Matter",
  id:"2.5",
  title:"Brownian Motion",
  objectives:[
    "Define Brownian motion.",
    "Describe Robert Brown's observations.",
    "Explain Brownian motion using the particle model.",
    "Distinguish between Brownian motion and diffusion.",
    "Explain why Brownian motion provides evidence for the existence of particles."
  ],
  success:[
    "Define Brownian motion.",
    "Explain why tiny particles move randomly.",
    "Describe how Brownian motion supports the particle model.",
    "Compare Brownian motion and diffusion."
  ],
  vocab:[
    ["Brownian Motion","The random movement of tiny particles suspended in a liquid or gas due to collisions with molecules of the surrounding substance."],
    ["Suspension","A mixture in which tiny solid particles are dispersed in a liquid or gas but do not dissolve."],
    ["Molecule","The smallest particle of a substance that retains its chemical properties."],
    ["Collision","When two particles strike each other."],
    ["Particle Model","A model stating that all matter is made of tiny particles that are in constant motion."]
  ],
  html:`
  <div class="content-body">
  <p><strong>Brownian motion</strong> is the random zigzag movement of tiny particles suspended in a liquid or gas. The particles move because they are constantly bombarded by fast-moving molecules of the surrounding fluid — the particles are not moving on their own.</p>

  <h4>A brief history</h4>
  <p>In 1827, Scottish botanist Robert Brown observed pollen grains suspended in water under a microscope, moving continuously in an irregular zigzag pattern. Later, scientists discovered the movement was caused by invisible water molecules colliding with the pollen grains — important evidence for the particle theory of matter.</p>

  <h4>Brownian motion vs diffusion</h4>
  <table class="data-table">
    <tr><th>Brownian Motion</th><th>Diffusion</th></tr>
    <tr><td>Random zigzag movement of suspended particles</td><td>Net movement of particles from high to low concentration</td></tr>
    <tr><td>Caused by collisions with surrounding molecules</td><td>Caused by the random motion of the particles themselves</td></tr>
    <tr><td>Observed under a microscope (or dust in sunlight)</td><td>Observed as substances spreading out</td></tr>
    <tr><td>Does not require a concentration gradient</td><td>Requires a concentration gradient</td></tr>
  </table>

  <h4>Factors affecting Brownian motion</h4>
  <ul>
    <li><strong>Temperature</strong> — higher temperature = more kinetic energy = more vigorous motion.</li>
    <li><strong>Particle size</strong> — smaller suspended particles move more noticeably.</li>
    <li><strong>Type of fluid</strong> — generally more noticeable in gases (faster-moving molecules).</li>
  </ul>
  <div class="example-box">Everyday examples: dust dancing in sunlight, smoke particles moving randomly, fat droplets in milk under a microscope.</div>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Brownian motion is caused by living organisms.</div>
    <div class="row right">Correct: It is caused by collisions with molecules.</div>
    <div class="row wrong">Incorrect: Molecules stop moving when a liquid appears still.</div>
    <div class="row right">Correct: Molecules are always moving unless at absolute zero (0 K).</div>
  </div>
  </div>`,
  quiz:[
    {q:"Brownian motion is caused by:",opts:["Gravity","Wind","Collisions with surrounding molecules","Magnetism"],a:2},
    {q:"Who first observed Brownian motion?",opts:["Isaac Newton","Robert Brown","Albert Einstein","John Dalton"],a:1},
    {q:"Brownian motion provides evidence that:",opts:["Matter is continuous","Molecules are stationary","Matter is made of tiny moving particles","Solids contain no particles"],a:2},
    {q:"Which statement is TRUE of diffusion but not Brownian motion?",opts:["It involves particles","It requires a concentration gradient","It happens in gases","It is random"],a:1}
  ]
},
{
  unit:"Unit 2 — States of Matter",
  id:"2.6",
  title:"Gas Pressure",
  objectives:[
    "Define gas pressure.",
    "Explain gas pressure using the particle model.",
    "Describe how temperature, volume, and the number of gas particles affect pressure.",
    "Relate gas pressure to everyday situations.",
    "Interpret simple pressure–temperature and pressure–volume relationships."
  ],
  success:[
    "Define gas pressure.",
    "Explain why gases exert pressure.",
    "Predict how changes in temperature and volume affect gas pressure.",
    "Apply knowledge to real-life examples."
  ],
  vocab:[
    ["Pressure","The force exerted per unit area."],
    ["Gas Pressure","The force produced when gas particles collide with the walls of a container."],
    ["Collision","When particles strike each other or the walls of a container."],
    ["Compression","Reducing the volume of a gas."],
    ["Expansion","Increasing the volume occupied by a gas."],
    ["Atmosphere","The layer of gases surrounding Earth that exerts atmospheric pressure."]
  ],
  html:`
  <div class="content-body">
  <p>Gas particles move randomly and constantly collide with the walls of their container. The force acting over the surface area of the container is called <strong>gas pressure</strong> (Pressure = Force ÷ Area). Millions of collisions every second create measurable pressure.</p>

  <h4>Factors affecting gas pressure</h4>
  <ul>
    <li><strong>Temperature</strong> — heating gives particles more kinetic energy; they move faster and collide more often and more forcefully → pressure increases (constant volume).</li>
    <li><strong>Volume</strong> — reducing volume means particles hit the walls more frequently → pressure increases. Increasing volume → pressure decreases.</li>
    <li><strong>Number of particles</strong> — more particles = more collisions = higher pressure.</li>
  </ul>

  <div class="example-box">Everyday examples: a football feels firmer in hot sun; pushing a syringe plunger increases pressure in the trapped air; inflating a bicycle tyre adds particles and raises pressure; pressure cookers raise the boiling point of water.</div>

  <p>The Earth's atmosphere exerts atmospheric pressure on everything, but we don't normally feel it because it acts equally in all directions.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Gases have no mass.</div>
    <div class="row right">Correct: Gases have mass and occupy space.</div>
    <div class="row wrong">Incorrect: Gas particles expand when heated.</div>
    <div class="row right">Correct: The particles themselves do not expand; they move faster and spread farther apart.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Gas pressure is caused by:",opts:["Gravity","Collisions of gas particles with the container walls","Magnetic forces","Chemical reactions"],a:1},
    {q:"What happens to the pressure of a gas if heated in a sealed container?",opts:["It decreases","It stays the same","It increases","It becomes zero"],a:2},
    {q:"What happens when the volume of a gas is decreased?",opts:["Pressure decreases","Pressure increases","Particles stop moving","The gas changes into a liquid"],a:1},
    {q:"Adding more gas particles to a container (fixed volume) causes pressure to:",opts:["Decrease","Stay the same","Increase","Become negative"],a:2}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.1",
  title:"The Structure of the Atom",
  objectives:[
    "Describe the structure of an atom.",
    "Identify the three subatomic particles.",
    "State the relative charges and masses of protons, neutrons, and electrons.",
    "Explain the arrangement of particles within an atom.",
    "Understand that atoms are the basic building blocks of matter."
  ],
  success:[
    "Describe the structure of an atom.",
    "Name the three subatomic particles.",
    "State the charge and relative mass of each subatomic particle.",
    "Explain where protons, neutrons, and electrons are found."
  ],
  vocab:[
    ["Atom","The smallest particle of an element that retains its chemical properties."],
    ["Nucleus","The dense central part of an atom containing protons and neutrons."],
    ["Proton","A positively charged particle found in the nucleus."],
    ["Neutron","A particle with no charge found in the nucleus."],
    ["Electron","A negatively charged particle that moves around the nucleus."],
    ["Subatomic Particle","A particle smaller than an atom, such as a proton, neutron, or electron."],
    ["Electron Shell","A region around the nucleus where electrons are found."]
  ],
  html:`
  <div class="content-body">
  <p>An <strong>atom</strong> is the smallest particle of an element that can exist while still keeping the properties of that element. About 100 million atoms placed side by side would measure roughly 1 cm.</p>

  <h4>Structure</h4>
  <p>The <strong>nucleus</strong> is the tiny, dense centre containing protons and neutrons — almost all of the atom's mass. <strong>Electron shells</strong> are regions around the nucleus where electrons are constantly moving; most of the atom's volume is empty space.</p>

  <table class="data-table">
    <tr><th>Particle</th><th>Symbol</th><th>Charge</th><th>Relative Mass</th><th>Location</th></tr>
    <tr><td>Proton</td><td>p⁺</td><td>+1</td><td>1</td><td>Nucleus</td></tr>
    <tr><td>Neutron</td><td>n⁰</td><td>0</td><td>1</td><td>Nucleus</td></tr>
    <tr><td>Electron</td><td>e⁻</td><td>−1</td><td>1/1836</td><td>Electron shells</td></tr>
  </table>

  <p>In a neutral atom, number of protons = number of electrons, so the overall charge is 0.</p>

  <h4>Historical models</h4>
  <ul>
    <li><strong>Dalton</strong> — atoms as tiny solid spheres.</li>
    <li><strong>Thomson</strong> — "plum pudding": electrons embedded in a positive sphere.</li>
    <li><strong>Rutherford</strong> — most of the atom is empty space; positive charge concentrated in a tiny nucleus.</li>
    <li><strong>Bohr</strong> — electrons move in fixed energy levels (shells); this is the model most used at IGCSE level.</li>
  </ul>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Electrons orbit exactly like planets.</div>
    <div class="row right">Correct: Electrons occupy energy levels (shells); modern science describes them as probability regions.</div>
    <div class="row wrong">Incorrect: The nucleus fills most of the atom.</div>
    <div class="row right">Correct: The nucleus is tiny but contains almost all the mass.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which particles are found in the nucleus?",opts:["Electrons only","Protons only","Protons and neutrons","Neutrons and electrons"],a:2},
    {q:"Which particle has a negative charge?",opts:["Proton","Neutron","Electron","Nucleus"],a:2},
    {q:"Which statement is correct?",opts:["Electrons have the greatest mass","Most of the atom is empty space","The nucleus is negatively charged","Neutrons have a positive charge"],a:1},
    {q:"A neutral magnesium atom has 12 protons. How many electrons does it have?",opts:["10","11","12","13"],a:2}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.2",
  title:"Atomic Number, Mass Number, and Isotopes",
  objectives:[
    "Define atomic number and mass number.",
    "Calculate the numbers of protons, neutrons, and electrons in an atom.",
    "Explain what isotopes are.",
    "Describe the properties of isotopes."
  ],
  success:[
    "Define atomic number and mass number.",
    "Calculate the number of protons, neutrons, and electrons in an atom.",
    "Explain what isotopes are.",
    "Identify isotopes of an element."
  ],
  vocab:[
    ["Atomic Number","The number of protons in the nucleus of an atom."],
    ["Mass Number","The total number of protons and neutrons in an atom."],
    ["Isotope","Atoms of the same element with the same number of protons but different numbers of neutrons."],
    ["Nucleon","A proton or neutron found in the nucleus."],
    ["Neutral Atom","An atom with equal numbers of protons and electrons."]
  ],
  html:`
  <div class="content-body">
  <p>The <strong>atomic number (Z)</strong> is the number of protons in the nucleus and determines which element an atom is — every carbon atom has 6 protons, every oxygen atom has 8. The <strong>mass number (A)</strong> is the total number of protons and neutrons: Mass Number = Protons + Neutrons.</p>

  <div class="example-box">Neutrons = Mass Number − Atomic Number<br>Oxygen-16: 16 − 8 = <strong>8 neutrons</strong><br>Sodium-23: 23 − 11 = <strong>12 neutrons</strong></div>

  <p>For a neutral atom, Electrons = Protons.</p>

  <h4>What are isotopes?</h4>
  <p><strong>Isotopes</strong> are atoms of the same element with the same number of protons but different numbers of neutrons — same atomic number, different mass number.</p>
  <table class="data-table">
    <tr><th>Isotope</th><th>Protons</th><th>Neutrons</th><th>Mass Number</th></tr>
    <tr><td>Carbon-12</td><td>6</td><td>6</td><td>12</td></tr>
    <tr><td>Carbon-13</td><td>6</td><td>7</td><td>13</td></tr>
    <tr><td>Carbon-14</td><td>6</td><td>8</td><td>14</td></tr>
  </table>
  <p>Isotopes of an element have the <strong>same chemical properties</strong> (same number of electrons) but <strong>different masses</strong> (different numbers of neutrons). Some are stable, others radioactive — e.g. carbon-14 is used for dating fossils; cobalt-60 for cancer treatment.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Atomic number = number of neutrons.</div>
    <div class="row right">Correct: Atomic number = number of protons.</div>
    <div class="row wrong">Incorrect: Isotopes are different elements.</div>
    <div class="row right">Correct: Isotopes are the same element because they have the same number of protons.</div>
    <div class="row wrong">Incorrect: Mass number is the same as relative atomic mass.</div>
    <div class="row right">Correct: Mass number refers to one atom; relative atomic mass is a weighted average of all isotopes.</div>
  </div>
  </div>`,
  quiz:[
    {q:"The atomic number is the number of:",opts:["Neutrons","Electrons","Protons","Nucleons"],a:2},
    {q:"Which statement about isotopes is correct?",opts:["They have different numbers of protons","They are different elements","They have the same number of protons but different numbers of neutrons","They have different chemical properties"],a:2},
    {q:"An atom has an atomic number of 15 and a mass number of 31. How many neutrons does it contain?",opts:["15","16","31","46"],a:1},
    {q:"An atom has 26 protons, 30 neutrons, and 26 electrons. What is its mass number?",opts:["26","30","56","4"],a:2}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.3",
  title:"Electron Arrangement and Electronic Configuration",
  objectives:[
    "Describe how electrons are arranged in shells around the nucleus.",
    "Write the electronic configuration of the first 20 elements.",
    "Use the Periodic Table to determine the number of electrons in an atom.",
    "Explain how electron arrangement relates to the position of an element in the Periodic Table."
  ],
  success:[
    "Explain how electrons are arranged in shells.",
    "Write electron configurations for the first 20 elements.",
    "Relate electron arrangements to groups and periods.",
    "Predict the number of valence electrons in an element."
  ],
  vocab:[
    ["Electron Shell","A region around the nucleus where electrons are found."],
    ["Electronic Configuration","The arrangement of electrons in shells around the nucleus."],
    ["Valence Electron","An electron in the outermost shell of an atom."],
    ["Energy Level","Another name for an electron shell."],
    ["Outer Shell","The shell furthest from the nucleus that contains electrons."]
  ],
  html:`
  <div class="content-body">
  <p>Electrons occupy regions around the nucleus called <strong>electron shells</strong>. For the first 20 elements, shells fill in the pattern <strong>2, 8, 8, 2</strong> — electrons always fill the lowest energy shell first.</p>

  <div class="example-box">Oxygen (atomic number 8): first shell = 2, second shell = 6 → configuration <strong>2,6</strong><br>Sodium (atomic number 11): 2,8,1</div>

  <table class="data-table">
    <tr><th>Element</th><th>Symbol</th><th>Atomic #</th><th>Configuration</th></tr>
    <tr><td>Carbon</td><td>C</td><td>6</td><td>2,4</td></tr>
    <tr><td>Oxygen</td><td>O</td><td>8</td><td>2,6</td></tr>
    <tr><td>Sodium</td><td>Na</td><td>11</td><td>2,8,1</td></tr>
    <tr><td>Chlorine</td><td>Cl</td><td>17</td><td>2,8,7</td></tr>
    <tr><td>Argon</td><td>Ar</td><td>18</td><td>2,8,8</td></tr>
    <tr><td>Calcium</td><td>Ca</td><td>20</td><td>2,8,8,2</td></tr>
  </table>

  <h4>Valence electrons, groups &amp; periods</h4>
  <p><strong>Valence electrons</strong> (outer shell) determine chemical behaviour. For Groups 1–7, the group number = number of valence electrons. The period number = number of occupied electron shells.</p>
  <div class="example-box">Chlorine 2,8,7 → 7 valence electrons → Group 7, Period 3 (3 occupied shells)</div>
  <p><strong>Noble gases</strong> (Group 18) have full outer shells (e.g. Neon 2,8), making them very stable and unreactive.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Electrons can be placed in any shell.</div>
    <div class="row right">Correct: Electrons fill the lowest available energy shell first.</div>
    <div class="row wrong">Incorrect: The atomic number equals the number of shells.</div>
    <div class="row right">Correct: The atomic number equals the number of protons (and electrons in a neutral atom).</div>
  </div>
  </div>`,
  quiz:[
    {q:"What is the electron configuration of magnesium (atomic number 12)?",opts:["2,10","2,8,2","2,6,4","2,8,1"],a:1},
    {q:"Which element has the electron configuration 2,8,7?",opts:["Fluorine","Oxygen","Chlorine","Sulfur"],a:2},
    {q:"How many valence electrons does phosphorus (2,8,5) have?",opts:["2","5","8","15"],a:1},
    {q:"Why is neon chemically unreactive?",opts:["It has no electrons","It has a full outer electron shell","It has no protons","It is a metal"],a:1}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.4",
  title:"Ions and Ionic Charges",
  objectives:[
    "Define an ion.",
    "Explain how positive and negative ions are formed.",
    "Predict the charges of ions formed by elements in the first 20 elements.",
    "Relate electron arrangement to ion formation.",
    "Write the symbols of common ions."
  ],
  success:[
    "Define an ion.",
    "Explain how atoms become positively or negatively charged.",
    "Predict the charge of ions formed by different elements.",
    "Write the symbols of common ions."
  ],
  vocab:[
    ["Ion","An atom or group of atoms with an overall electrical charge because it has gained or lost electrons."],
    ["Cation","A positively charged ion formed when electrons are lost."],
    ["Anion","A negatively charged ion formed when electrons are gained."],
    ["Ionic Charge","The overall positive or negative charge on an ion."],
    ["Valence Electrons","Electrons in the outermost shell of an atom."]
  ],
  html:`
  <div class="content-body">
  <p>An <strong>ion</strong> is an atom (or group of atoms) that has gained or lost electrons, giving it an overall electrical charge. Protons never change in ordinary chemical reactions — only electrons move.</p>

  <p>Atoms are most stable with a full outer electron shell, often matching the nearest noble gas. To reach this, atoms lose or gain electrons.</p>

  <div class="example-box"><strong>Sodium</strong> (2,8,1) loses 1 electron → 2,8 → <strong>Na⁺</strong> (+1)<br><strong>Magnesium</strong> (2,8,2) loses 2 electrons → 2,8 → <strong>Mg²⁺</strong><br><strong>Chlorine</strong> (2,8,7) gains 1 electron → 2,8,8 → <strong>Cl⁻</strong> (−1)<br><strong>Oxygen</strong> (2,6) gains 2 electrons → 2,8 → <strong>O²⁻</strong></div>

  <table class="data-table">
    <tr><th>Group</th><th>Electrons Gained/Lost</th><th>Ion Charge</th></tr>
    <tr><td>Group 1</td><td>Lose 1</td><td>+1</td></tr>
    <tr><td>Group 2</td><td>Lose 2</td><td>+2</td></tr>
    <tr><td>Group 3</td><td>Lose 3</td><td>+3</td></tr>
    <tr><td>Group 5</td><td>Gain 3</td><td>−3</td></tr>
    <tr><td>Group 6</td><td>Gain 2</td><td>−2</td></tr>
    <tr><td>Group 7</td><td>Gain 1</td><td>−1</td></tr>
    <tr><td>Group 18</td><td>Usually none</td><td>0</td></tr>
  </table>

  <p><strong>Metals</strong> (left side of the Periodic Table) usually lose electrons → cations. <strong>Non-metals</strong> (right side) usually gain electrons → anions. Noble gases already have full outer shells so rarely form ions.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Atoms lose protons to form ions.</div>
    <div class="row right">Correct: Only electrons are gained or lost in ordinary chemical reactions.</div>
    <div class="row wrong">Incorrect: Chlorine loses one electron.</div>
    <div class="row right">Correct: Chlorine gains one electron to complete its outer shell.</div>
  </div>
  </div>`,
  quiz:[
    {q:"A sodium atom forms a sodium ion by:",opts:["Gaining one electron","Losing one electron","Gaining one proton","Losing one neutron"],a:1},
    {q:"Which ion is formed by oxygen?",opts:["O⁺","O²⁺","O²⁻","O⁻"],a:2},
    {q:"Which group of elements usually forms −1 ions?",opts:["Group 1","Group 2","Group 7","Group 18"],a:2},
    {q:"Magnesium (2,8,2) forms which ion?",opts:["Mg⁺","Mg²⁺","Mg²⁻","Mg³⁺"],a:1},
    {q:"Metals on the left of the Periodic Table usually form:",opts:["Anions","Cations","No ions","Noble gases"],a:1}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.5",
  title:"Introduction to Chemical Bonding",
  objectives:[
    "Define chemical bonding.",
    "Explain why atoms form chemical bonds.",
    "Distinguish between ionic and covalent bonding.",
    "Describe how atoms achieve stable electron arrangements through bonding."
  ],
  success:[
    "Define chemical bonding.",
    "Explain why atoms bond.",
    "Compare ionic and covalent bonding.",
    "Identify whether a compound is ionic or covalent."
  ],
  vocab:[
    ["Chemical Bond","The force that holds atoms or ions together in a substance."],
    ["Ionic Bond","The electrostatic attraction between oppositely charged ions."],
    ["Covalent Bond","A bond formed when atoms share pairs of electrons."],
    ["Compound","A substance made from two or more different elements chemically combined."],
    ["Stable Electron Configuration","A full outer electron shell, making an atom less reactive."]
  ],
  html:`
  <div class="content-body">
  <p>Atoms bond because they become more stable with a full outer electron shell. A <strong>chemical bond</strong> is the force that holds atoms or ions together in a substance.</p>

  <h4>Two main types of bonding</h4>
  <table class="data-table">
    <tr><th>Ionic Bonding</th><th>Covalent Bonding</th></tr>
    <tr><td>Electrons are transferred</td><td>Electrons are shared</td></tr>
    <tr><td>Forms ions</td><td>Forms molecules</td></tr>
    <tr><td>Usually metal + non-metal</td><td>Usually non-metal + non-metal</td></tr>
    <tr><td>Strong electrostatic attraction</td><td>Shared electron pairs hold atoms together</td></tr>
  </table>

  <div class="example-box"><strong>Ionic — NaCl:</strong> Sodium (2,8,1) loses 1 electron → Na⁺. Chlorine (2,8,7) gains 1 electron → Cl⁻. The opposite charges attract, forming an ionic bond.<br><strong>Covalent — H₂:</strong> each hydrogen atom shares one electron with the other, forming a single shared pair (H—H).</div>

  <h4>Examples</h4>
  <p><strong>Ionic compounds:</strong> table salt (NaCl), magnesium oxide (MgO), calcium chloride (CaCl₂).<br><strong>Covalent compounds:</strong> water (H₂O), carbon dioxide (CO₂), methane (CH₄), oxygen (O₂).</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Ionic bonds involve sharing electrons.</div>
    <div class="row right">Correct: Ionic bonds involve the transfer of electrons.</div>
    <div class="row wrong">Incorrect: All compounds contain ions.</div>
    <div class="row right">Correct: Covalent compounds contain neutral molecules, not ions.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Ionic bonding occurs through:",opts:["Sharing electrons","Transfer of electrons","Sharing protons","Transfer of neutrons"],a:1},
    {q:"Covalent bonding usually occurs between:",opts:["Two metals","A metal and a non-metal","Two non-metals","Noble gases"],a:2},
    {q:"Which compound contains ionic bonds?",opts:["H₂O","CO₂","CH₄","NaCl"],a:3},
    {q:"Why do atoms form chemical bonds?",opts:["To increase their mass","To achieve a full, stable outer electron shell","To become radioactive","To lose protons"],a:1}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.6",
  title:"Atomic Structure Review and Assessment",
  objectives:[
    "Review all the key concepts from Unit 3 so far.",
    "Apply knowledge of atomic structure to solve problems.",
    "Interpret electron configurations and ion formation.",
    "Demonstrate readiness for deeper study of chemical bonding."
  ],
  success:[
    "Identify the parts of an atom.",
    "Calculate the numbers of protons, neutrons, and electrons.",
    "Write electron configurations for the first 20 elements.",
    "Predict the ions formed by common elements.",
    "Explain the difference between ionic and covalent bonding."
  ],
  vocab:[
    ["Concept Map","A diagram showing how ideas connect to one another."],
    ["Cation","A positively charged ion formed when a metal atom loses electrons."],
    ["Anion","A negatively charged ion formed when a non-metal atom gains electrons."]
  ],
  html:`
  <div class="content-body">
  <p>This lesson consolidates Lessons 3.1–3.5 before moving into deeper bonding topics.</p>

  <table class="data-table">
    <tr><th>Particle</th><th>Charge</th><th>Relative Mass</th><th>Location</th></tr>
    <tr><td>Proton</td><td>+1</td><td>1</td><td>Nucleus</td></tr>
    <tr><td>Neutron</td><td>0</td><td>1</td><td>Nucleus</td></tr>
    <tr><td>Electron</td><td>−1</td><td>1/1836</td><td>Electron shells</td></tr>
  </table>

  <p><strong>Atomic number (Z)</strong> = protons. <strong>Mass number (A)</strong> = protons + neutrons. Neutrons = A − Z. For a neutral atom, electrons = protons.</p>
  <p>Electron shells fill in the order <strong>2,8,8,2</strong> for the first 20 elements.</p>

  <h4>Ion formation recap</h4>
  <table class="data-table">
    <tr><th>Atom</th><th>Ion</th></tr>
    <tr><td>Na</td><td>Na⁺</td></tr>
    <tr><td>Mg</td><td>Mg²⁺</td></tr>
    <tr><td>Ca</td><td>Ca²⁺</td></tr>
    <tr><td>Cl</td><td>Cl⁻</td></tr>
    <tr><td>O</td><td>O²⁻</td></tr>
  </table>
  <p>Metals lose electrons to form <strong>cations</strong>; non-metals gain electrons to form <strong>anions</strong>. Ionic bonding transfers electrons between a metal and non-metal; covalent bonding shares electrons between non-metals.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Atomic number = neutrons.</div>
    <div class="row right">Correct: Atomic number = protons.</div>
    <div class="row wrong">Incorrect: Covalent bonding forms ions.</div>
    <div class="row right">Correct: Covalent bonding forms molecules.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which particle determines the identity of an element?",opts:["Electron","Neutron","Proton","Nucleus"],a:2},
    {q:"An atom has 17 protons and 18 electrons. What is it?",opts:["Neutral atom","Positive ion","Negative ion","Isotope"],a:2},
    {q:"What is the electron configuration of aluminium (atomic number 13)?",opts:["2,8,2","2,8,3","2,6,5","2,8,8"],a:1},
    {q:"Which substance contains covalent bonds?",opts:["NaCl","MgO","H₂O","CaCl₂"],a:2},
    {q:"Which ion does calcium form?",opts:["Ca⁺","Ca²⁺","Ca²⁻","Ca⁻"],a:1}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.7",
  title:"Relative Atomic Mass and the Mass Spectrometer",
  objectives:[
    "Define relative atomic mass.",
    "Explain why elements have decimal atomic masses.",
    "Calculate relative atomic mass from isotope abundance.",
    "Describe the basic principles of a mass spectrometer."
  ],
  success:[
    "Explain why chlorine has a relative atomic mass of 35.5 instead of a whole number.",
    "Calculate relative atomic mass using isotope data.",
    "Describe how a mass spectrometer works.",
    "Explain how isotopes are separated and detected."
  ],
  vocab:[
    ["Relative Atomic Mass (Ar)","The average mass of atoms of an element compared with carbon-12."],
    ["Abundance","The percentage of each isotope found naturally."],
    ["Mass Spectrometer","An instrument used to identify isotopes and measure their abundance."],
    ["Ionisation","The process of turning atoms into charged particles."],
    ["Deflection","The change in direction of moving ions in a magnetic field."]
  ],
  html:`
  <div class="content-body">
  <p><strong>Relative atomic mass (Ar)</strong> is the average mass of atoms of an element compared with carbon-12. Because elements exist as mixtures of isotopes, atomic masses on the Periodic Table are usually not whole numbers.</p>

  <div class="example-box"><strong>Chlorine:</strong> Cl-35 (75%), Cl-37 (25%)<br>Ar = [(35×75)+(37×25)] ÷ 100 = (2625+925) ÷ 100 = <strong>35.5</strong></div>
  <div class="example-box"><strong>Magnesium:</strong> Mg-24 (79%), Mg-25 (10%), Mg-26 (11%)<br>Ar = [(24×79)+(25×10)+(26×11)] ÷ 100 = <strong>24.32</strong></div>

  <h4>How a mass spectrometer works</h4>
  <ol>
    <li><strong>Ionisation</strong> — atoms are converted into positive ions (e.g. Mg → Mg⁺ + e⁻).</li>
    <li><strong>Acceleration</strong> — ions are accelerated by an electric field.</li>
    <li><strong>Deflection</strong> — ions pass through a magnetic field; lighter ions deflect more, heavier ions deflect less.</li>
    <li><strong>Detection</strong> — a detector records the ions, showing which isotopes are present and their abundance.</li>
  </ol>
  <p>A chlorine mass spectrum would show a large peak at mass 35 and a smaller peak at mass 37 — revealing two isotopes.</p>
  <p>Isotopes are chemically similar because they have the same number of protons and electrons (same electron arrangement); they differ only in mass due to different neutron numbers.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Relative atomic mass is the mass of one atom.</div>
    <div class="row right">Correct: It is a weighted average based on isotope abundance.</div>
    <div class="row wrong">Incorrect: The most common isotope always gives the exact atomic mass.</div>
    <div class="row right">Correct: Relative atomic mass accounts for all isotopes and their abundances.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Relative atomic mass depends on:",opts:["Number of electrons only","Isotope masses and abundance","Number of neutrons only","The size of the atom"],a:1},
    {q:"Why does chlorine have a relative atomic mass of 35.5?",opts:["Chlorine atoms are half atoms","Chlorine contains different isotopes","Chlorine has no neutrons","Chlorine changes elements"],a:1},
    {q:"In a mass spectrometer, ions are separated according to their:",opts:["Colour","Density only","Mass-to-charge ratio","Temperature"],a:2},
    {q:"An element has isotopes A (mass 63, 70%) and B (mass 65, 30%). What is its relative atomic mass?",opts:["63.0","63.6","64.0","65.0"],a:1}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.8",
  title:"Atomic Structure Problem Solving and Exam Skills",
  objectives:[
    "Apply atomic structure knowledge to unfamiliar questions.",
    "Solve problems involving protons, neutrons, electrons, ions, and isotopes.",
    "Interpret information from the Periodic Table.",
    "Avoid common exam mistakes."
  ],
  success:[
    "Calculate numbers of protons, neutrons, and electrons.",
    "Work out ion charges.",
    "Write electron configurations.",
    "Explain isotope and ion formation.",
    "Answer atomic structure exam questions clearly."
  ],
  vocab:[
    ["Proton Number","Another name for atomic number; number of protons."],
    ["Nucleon Number","Another name for mass number; protons + neutrons."],
    ["Ion","A charged particle formed by gaining or losing electrons."]
  ],
  html:`
  <div class="content-body">
  <p>A reliable method for atomic structure questions: <strong>Step 1</strong> find the atomic number (= protons). <strong>Step 2</strong> find the mass number (= protons + neutrons), so neutrons = mass number − atomic number. <strong>Step 3</strong> determine electrons: for a neutral atom, electrons = protons; for a positive ion, electrons have been lost; for a negative ion, electrons have been gained.</p>

  <div class="example-box"><strong>Mg²⁺</strong> (atomic number 12): normally 12 electrons, loses 2 → <strong>10 electrons</strong>.<br><strong>Atomic number 17</strong> → configuration 2,8,7 → outer electrons = 7 → <strong>Group 7, Period 3</strong> (3 occupied shells).</div>

  <h4>Comparing atoms, ions, and isotopes</h4>
  <table class="data-table">
    <tr><th>Feature</th><th>Atom</th><th>Ion</th><th>Isotope</th></tr>
    <tr><td>Protons</td><td>Same</td><td>Same</td><td>Same</td></tr>
    <tr><td>Electrons</td><td>Neutral</td><td>Different</td><td>Same</td></tr>
    <tr><td>Neutrons</td><td>Same</td><td>Same</td><td>Different</td></tr>
    <tr><td>Charge</td><td>0</td><td>Positive or negative</td><td>0</td></tr>
  </table>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Atomic number = protons + neutrons.</div>
    <div class="row right">Correct: Atomic number = protons only.</div>
    <div class="row wrong">Incorrect: Ions are formed by changing protons.</div>
    <div class="row right">Correct: Ions form by gaining or losing electrons.</div>
    <div class="row wrong">Incorrect: Chlorine gains two electrons.</div>
    <div class="row right">Correct: Chlorine gains one electron to complete its outer shell.</div>
  </div>
  </div>`,
  quiz:[
    {q:"An atom contains 19 protons, 20 neutrons, and 19 electrons. What is its mass number?",opts:["19","20","39","58"],a:2},
    {q:"An ion contains 17 protons and 18 electrons. Is it positive or negative, and what is its symbol?",opts:["Positive, Cl⁺","Negative, Cl⁻","Positive, Cl²⁺","Negative, Cl²⁻"],a:1},
    {q:"An element has electron configuration 2,8,2. What ion does it form?",opts:["X⁺","X²⁺","X²⁻","X³⁺"],a:1},
    {q:"An ion has 13 protons and 10 electrons. What is its charge?",opts:["1+","2+","3+","3−"],a:2}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.9",
  title:"Radioactivity and Nuclear Stability",
  objectives:[
    "Define radioactivity.",
    "Explain why some nuclei are unstable.",
    "Describe alpha, beta, and gamma radiation.",
    "Compare the properties of different types of radiation.",
    "Explain the uses and dangers of radioactive materials."
  ],
  success:[
    "Define radioactive decay.",
    "Explain why unstable nuclei release radiation.",
    "Identify alpha, beta, and gamma radiation.",
    "Compare their penetration and ionising abilities.",
    "Describe practical uses of radioactivity."
  ],
  vocab:[
    ["Radioactivity","The spontaneous emission of radiation from an unstable nucleus."],
    ["Radiation","Energy or particles released from an unstable nucleus."],
    ["Decay","The process where an unstable nucleus changes into a more stable one."],
    ["Ionising Radiation","Radiation with enough energy to remove electrons from atoms."],
    ["Half-life","The time taken for half of the radioactive nuclei in a sample to decay."]
  ],
  html:`
  <div class="content-body">
  <p><strong>Radioactivity</strong> is the spontaneous emission of radiation from an unstable atomic nucleus as it changes into a more stable form. Decay happens naturally, cannot be stopped, is random, and does not depend on temperature or pressure.</p>

  <h4>Three types of nuclear radiation</h4>
  <table class="data-table">
    <tr><th>Radiation</th><th>Composition</th><th>Charge</th><th>Ionising Power</th><th>Penetration</th><th>Stopped By</th></tr>
    <tr><td>Alpha (α)</td><td>2 protons + 2 neutrons (He nucleus)</td><td>+2</td><td>Very high</td><td>Very low</td><td>Paper, skin, a few cm of air</td></tr>
    <tr><td>Beta (β)</td><td>Fast-moving electron</td><td>−1</td><td>Medium</td><td>Medium</td><td>Thin aluminium sheet</td></tr>
    <tr><td>Gamma (γ)</td><td>Electromagnetic wave</td><td>0</td><td>Low</td><td>Very high</td><td>Thick lead / concrete</td></tr>
  </table>

  <h4>Balancing nuclear equations</h4>
  <p><strong>Alpha decay:</strong> atomic number decreases by 2, mass number decreases by 4.<br><strong>Beta decay:</strong> a neutron changes into a proton + electron; atomic number increases by 1, mass number stays the same.</p>

  <h4>Half-life</h4>
  <p>The <strong>half-life</strong> is the time for half of the radioactive nuclei in a sample to decay.</p>
  <div class="example-box">1000 atoms → after 1 half-life: 500 → after 2: 250 → after 3: 125</div>

  <h4>Uses</h4>
  <ul>
    <li>Cancer treatment and medical imaging (gamma radiation, e.g. Technetium-99m)</li>
    <li>Carbon dating (Carbon-14)</li>
    <li>Smoke detectors (Americium-241, alpha radiation)</li>
  </ul>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Radioactive materials stop decaying when stored safely.</div>
    <div class="row right">Correct: Radioactive decay continues naturally regardless of storage.</div>
    <div class="row wrong">Incorrect: Gamma radiation is a particle.</div>
    <div class="row right">Correct: Gamma radiation is electromagnetic energy, not a particle.</div>
  </div>
  </div>`,
  quiz:[
    {q:"Which radiation has the greatest penetrating ability?",opts:["Alpha","Beta","Gamma","Proton"],a:2},
    {q:"Alpha radiation contains:",opts:["Electrons","Two protons and two neutrons","Electromagnetic waves","Neutrons only"],a:1},
    {q:"During beta decay, a neutron changes into:",opts:["A proton and electron","Two protons","A gamma ray","An alpha particle"],a:0},
    {q:"A sample starts with 1600 atoms and has a half-life of 8 days. How many atoms remain after 16 days?",opts:["800","400","200","100"],a:1}
  ]
},
{
  unit:"Unit 3 — Atomic Structure",
  id:"3.10",
  title:"Unit 3 Mastery Review",
  objectives:[
    "Consolidate all Unit 3 concepts.",
    "Connect atomic structure ideas together.",
    "Solve multi-step exam questions.",
    "Prepare for the Unit 3 assessment."
  ],
  success:[
    "Explain the structure of an atom.",
    "Calculate atomic number, mass number, and isotope information.",
    "Write electron configurations.",
    "Predict ion formation.",
    "Explain radioactive decay."
  ],
  vocab:[
    ["Weighted Average","An average that accounts for how common each value is, used to calculate relative atomic mass."],
    ["Nuclear Stability","How likely a nucleus is to remain unchanged rather than decay."]
  ],
  html:`
  <div class="content-body">
  <p>This final review pulls together the whole unit: structure of the atom, isotopes, relative atomic mass, electron arrangement, ions, bonding, and radioactivity.</p>

  <table class="data-table">
    <tr><th>Topic</th><th>Key Idea</th></tr>
    <tr><td>Structure of the atom</td><td>Protons (+1) and neutrons (0) in the nucleus; electrons (−1) in shells</td></tr>
    <tr><td>Atomic/mass number</td><td>Z = protons; A = protons + neutrons; neutrons = A − Z</td></tr>
    <tr><td>Isotopes</td><td>Same protons, different neutrons</td></tr>
    <tr><td>Relative atomic mass</td><td>Weighted average of isotope masses and abundances</td></tr>
    <tr><td>Electron arrangement</td><td>Shells fill 2,8,8,2; group = outer electrons, period = number of shells</td></tr>
    <tr><td>Ions</td><td>Metals lose electrons (cations); non-metals gain electrons (anions)</td></tr>
    <tr><td>Bonding</td><td>Ionic = transfer of electrons; covalent = sharing of electrons</td></tr>
    <tr><td>Radioactivity</td><td>Alpha, beta, gamma radiation from unstable nuclei; half-life measures decay rate</td></tr>
  </table>

  <div class="example-box"><strong>Worked review example:</strong> Element X has atomic number 20, mass number 40 → 20 protons, 20 neutrons, 20 electrons, configuration 2,8,8,2, Group 2, forms Ca²⁺ by losing 2 outer electrons to achieve a stable full shell.</div>

  <p>Use this checklist before the assessment: describe atomic structure; calculate protons/neutrons/electrons; explain isotopes; calculate relative atomic mass; write electron configurations; predict ion charges; explain ionic and covalent bonding; describe alpha, beta and gamma radiation; calculate half-life.</p>

  <div class="misconceptions">
    <div class="row wrong">Incorrect: Treating isotopes as chemically different because their masses differ.</div>
    <div class="row right">Correct: Isotopes react the same way chemically since they have identical electron arrangements.</div>
  </div>
  </div>`,
  quiz:[
    {q:"An atom has 17 protons and 18 neutrons. What is its electron configuration?",opts:["2,8,7","2,8,8","2,7,8","2,8,6"],a:0},
    {q:"Why does magnesium form Mg²⁺?",opts:["It gains two electrons to fill its outer shell","It loses two outer electrons to achieve a full outer shell","It loses two protons","It gains two protons"],a:1},
    {q:"Why do carbon-12 and carbon-14 have similar chemical properties?",opts:["They have the same number of neutrons","They have the same number of electrons and electron arrangement","They have different numbers of protons","They are different elements"],a:1},
    {q:"Which two properties does gamma radiation have?",opts:["High charge and high mass","No charge and very high penetration","Negative charge and low penetration","Positive charge and medium penetration"],a:1}
  ]
}
];

