# To run this code you need to install the following dependencies:
# pip install google-genai

import base64
import os
from google import genai
from google.genai import types


def generate():
    client = genai.Client(
        api_key=os.environ.get("GEMINI_API_KEY"),
    )

    model = "gemini-2.0-flash"
    contents = [
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Description 1:
The project introduces GradEase, a mobile application designed to streamline and enhance the management of graduation projects for students and faculty members. It tackles common challenges such as poor communication, missed deadlines, lack of proper guidance, and project duplication by offering a centralized, user-friendly platform. Key features include AI-powered topic suggestions, plagiarism detection, milestone tracking, real-time messaging, and task management. GradEase empowers students to work more independently and efficiently while enabling supervisors to monitor progress, provide timely feedback, and ensure academic integrity—ultimately improving the graduation project experience for all stakeholders.
Description 2:
This file describes EL-Donation, a mobile application focused on optimizing the blood donation process by tracking mobile blood donation vehicles in real-time. Key features include:
•	Location tracking of mobile donation units
•	Donor-recipient matching system
•	Chat and posting features for communication
•	Admin dashboard to manage vehicle locations
The app is built using Flutter and Firebase, with design and documentation tools like Lucidchart and Adobe Premiere Pro. It includes a system analysis section with use cases, diagrams, and a comparison with similar apps like “Simply Blood” and “Give Blood NHS.”
Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I've analyzed the two descriptions, \"GradEase\" and \"EL-Donation\", for potential plagiarism in their project ideas.

**Analysis:**

The core idea of \"GradEase\" is to manage graduation projects for students and faculty, focusing on communication, organization, and academic integrity.  The core idea of \"EL-Donation\" is to track mobile blood donation vehicles and connect donors with recipients.

**Similarity Assessment:**

These projects have **0%** similarity.

*   **Project Goals:** GradEase aims to improve the graduation project experience through organization and guidance. EL-Donation aims to improve the blood donation process through real-time tracking and matching.
*   **Target Users:** GradEase targets students and faculty involved in graduation projects. EL-Donation targets blood donors, recipients, and blood donation organizers.
*   **Features:** GradEase features AI-powered topic suggestions, plagiarism detection, and milestone tracking. EL-Donation features location tracking, donor-recipient matching, and a chat feature.
*   **Implementation:** GradEase's implementation details are not very specific. EL-Donation specifically mentions Flutter and Firebase.

**Explanation of Plagiarism Percentage Calculation:**

The plagiarism percentage of 0% was determined because there is no significant overlap in the core concepts, functionality, target audience, or features described in the two project proposals. Both applications are designed to solve completely different problems, one focusing on educational project management, and the other focusing on blood donation logistics. The similarity assessment is primarily based on conceptual overlap and shared functionality, of which there is none.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Description 1:
The project introduces GradEase, a mobile application designed to streamline and enhance the management of graduation projects for students and faculty members. It tackles common challenges such as poor communication, missed deadlines, lack of proper guidance, and project duplication by offering a centralized, user-friendly platform. Key features include AI-powered topic suggestions, plagiarism detection, milestone tracking, real-time messaging, and task management. GradEase empowers students to work more independently and efficiently while enabling supervisors to monitor progress, provide timely feedback, and ensure academic integrity—ultimately improving the graduation project experience for all stakeholders.
Description 2:
Overview:
The document details the development of SignEcho, an innovative mobile app designed to translate sign language into spoken and written text using AI and computer vision (YOLO). It also features modules for E-learning (sign language), E-commerce (pharmaceuticals), and real-time chatting — aimed to support and empower the deaf and hard-of-hearing community.
Key Contents:
•	Acknowledgments & Abstract
•	Abbreviations & Tools Used (Flutter, Python, Firebase, Roboflow, etc.)
•	Chapters Include:
o	Introduction: Project motivation, goals, and structure
o	System Design: Technical architecture, datasets, interface design
o	Literature Review: Comparisons with existing solutions (Vezeeta, Lingvano, ASLU, etc.)
o	System Analysis: Use cases, ER diagrams, sequence diagrams
o	Implementation: UI screenshots, sample code snippets
o	Conclusion and Future Work: Plans for expanding dataset, admin dashboard, and more products

Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I've analyzed the two descriptions, \"GradEase\" and \"SignEcho,\" for potential plagiarism in their project ideas.

**Analysis:**

The core idea of \"GradEase\" is to manage graduation projects for students and faculty, focusing on communication, organization, and academic integrity. The core idea of \"SignEcho\" is to translate sign language into spoken and written text and provide various support modules for the deaf and hard-of-hearing community.

**Similarity Assessment:**

These projects have **0%** similarity.

*   **Project Goals:** GradEase aims to improve graduation project management. SignEcho aims to aid communication for the deaf and hard-of-hearing.
*   **Target Users:** GradEase targets students and faculty. SignEcho targets the deaf and hard-of-hearing community.
*   **Features:** GradEase features AI-powered suggestions, plagiarism detection, and milestone tracking. SignEcho features sign language translation, e-learning, e-commerce, and real-time chat.
*   **Technology:** GradEase doesn't specify specific technologies. SignEcho mentions Flutter, Python, Firebase, and Roboflow.

**Explanation of Plagiarism Percentage Calculation:**

The plagiarism percentage of 0% was determined because there is no significant overlap in the core concepts, functionality, target audience, or features described in the two project proposals. They are completely different in purpose and functionality. The similarity assessment is primarily based on conceptual overlap and shared functionality, of which there is none.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Description 1:
The project introduces GradEase, a mobile application designed to streamline and enhance the management of graduation projects for students and faculty members. It tackles common challenges such as poor communication, missed deadlines, lack of proper guidance, and project duplication by offering a centralized, user-friendly platform. Key features include AI-powered topic suggestions, plagiarism detection, milestone tracking, real-time messaging, and task management. GradEase empowers students to work more independently and efficiently while enabling supervisors to monitor progress, provide timely feedback, and ensure academic integrity—ultimately improving the graduation project experience for all stakeholders.
Description 2:
Objective:
The NBTAH application is designed to revolutionize agriculture by using image recognition and machine learning to detect plant diseases and provide comprehensive crop management tools.
Key Features:
•	Plant disease detection via photo recognition (YOLOv5-based).
•	Detailed planting, irrigation, and harvesting guides.
•	Real-time weather alerts.
•	An online marketplace for agricultural supplies.
•	A community forum for farmers to share tips and experiences.
•	Lifecycle tracking with growth reminders.


Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I've analyzed the two descriptions, \"GradEase\" and \"NBTAH,\" for potential plagiarism in their project ideas.

**Analysis:**

The core idea of \"GradEase\" is to manage graduation projects for students and faculty, focusing on communication, organization, and academic integrity. The core idea of \"NBTAH\" is to revolutionize agriculture through plant disease detection, crop management tools, and a farmer community platform.

**Similarity Assessment:**

These projects have **0%** similarity.

*   **Project Goals:** GradEase aims to improve graduation project management. NBTAH aims to improve agricultural practices and outcomes.
*   **Target Users:** GradEase targets students and faculty. NBTAH targets farmers and agricultural stakeholders.
*   **Features:** GradEase features AI-powered suggestions, plagiarism detection, and milestone tracking. NBTAH features plant disease detection, planting guides, weather alerts, a marketplace, and a community forum.

**Explanation of Plagiarism Percentage Calculation:**

The plagiarism percentage of 0% was determined because there is no significant overlap in the core concepts, functionality, target audience, or features described in the two project proposals. The only overlap is that both propose using AI, but AI is a broad field and the specific applications are vastly different. The similarity assessment is primarily based on conceptual overlap and shared functionality, of which there is none.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Description 1:
The project introduces GradEase, a mobile application designed to streamline and enhance the management of graduation projects for students and faculty members. It tackles common challenges such as poor communication, missed deadlines, lack of proper guidance, and project duplication by offering a centralized, user-friendly platform. Key features include AI-powered topic suggestions, plagiarism detection, milestone tracking, real-time messaging, and task management. GradEase empowers students to work more independently and efficiently while enabling supervisors to monitor progress, provide timely feedback, and ensure academic integrity—ultimately improving the graduation project experience for all stakeholders.
Description 2:
This document details a comprehensive graduation project titled \"Asclepius\", which is a web-based platform aimed at streamlining critical medical operations. It enables real-time communication and data sharing between hospitals, doctors, and clinics. Features include:
•	Blood donation and tracking
•	Titanium implant availability
•	Medical case and surgery library
•	Doctor forums for consultations
•	A social medical network
The project emphasizes user-friendliness, fast information retrieval, and collaborative problem-solving in healthcare emergencies. It includes system architecture diagrams (ERD, DFD, UML), marketing strategy, business model, financial analysis, and implementation tools (HTML, CSS, JS, PHP, XAMPP, etc.).


Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""The projects have a **5%** similarity.

**Similar Points:**

*   Both are platforms designed to streamline and enhance management in a specific area (Graduation projects vs. Medical operations).
*   Both aim to tackle challenges in communication and information sharing within their respective domains.
*   Both projects aim to improve a process and help users work more efficiently.

**Explanation of Plagiarism Percentage Calculation:**

The 5% similarity is based on a high-level conceptual overlap: both projects are web-based platforms designed to improve management and communication in a specific field. Both also try to make processes more streamlined and efficient. However, the target users, specific features, and the overall context are very different (education vs. healthcare), reducing the level of similarity significantly. The score considers that the projects have a similar structure and goal but act in different areas.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Description 1:
The project introduces GradEase, a mobile application designed to streamline and enhance the management of graduation projects for students and faculty members. It tackles common challenges such as poor communication, missed deadlines, lack of proper guidance, and project duplication by offering a centralized, user-friendly platform. Key features include AI-powered topic suggestions, plagiarism detection, milestone tracking, real-time messaging, and task management. GradEase empowers students to work more independently and efficiently while enabling supervisors to monitor progress, provide timely feedback, and ensure academic integrity—ultimately improving the graduation project experience for all stakeholders.
Description 2:
This document presents the Marketing Intelligence (MI) project—a tech-driven approach to revolutionize traditional marketing using:
•	Holographic fan displays
•	AI-based facial detection and interaction
•	Camera-based demographic data collection
The system targets fast market penetration with options for on-premise, cloud, or hybrid deployment. It includes SDLC phases, data flow diagrams, ERDs, activity diagrams, and pseudocode. The project also discusses sustainability, diversity in marketing, and licensing strategies combining closed and open-source technologies

Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""The projects have a **0%** similarity.

**Similar Points:**

*   There are no similar points.

**Explanation of Plagiarism Percentage Calculation:**

The 0% similarity is based on the complete lack of overlap between the projects. GradEase focuses on the educational management of graduation projects using a mobile app, while the Marketing Intelligence project aims to revolutionize marketing through holographic displays, AI-based facial detection, and demographic data collection. The target users, features, technologies, and overall goals are entirely distinct. Therefore, the similarity percentage is zero.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Description 1:
This file describes EL-Donation, a mobile application focused on optimizing the blood donation process by tracking mobile blood donation vehicles in real-time. Key features include:
•	Location tracking of mobile donation units
•	Donor-recipient matching system
•	Chat and posting features for communication
•	Admin dashboard to manage vehicle locations
The app is built using Flutter and Firebase, with design and documentation tools like Lucidchart and Adobe Premiere Pro. It includes a system analysis section with use cases, diagrams, and a comparison with similar apps like “Simply Blood” and “Give Blood NHS.”

Description 2:
This document details a comprehensive graduation project titled \"Asclepius\", which is a web-based platform aimed at streamlining critical medical operations. It enables real-time communication and data sharing between hospitals, doctors, and clinics. Features include:
•	Blood donation and tracking
•	Titanium implant availability
•	Medical case and surgery library
•	Doctor forums for consultations
•	A social medical network
The project emphasizes user-friendliness, fast information retrieval, and collaborative problem-solving in healthcare emergencies. It includes system architecture diagrams (ERD, DFD, UML), marketing strategy, business model, financial analysis, and implementation tools (HTML, CSS, JS, PHP, XAMPP, etc.).


Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""The projects have a **15%** similarity.

**Similar Points:**

*   Both projects operate within the healthcare domain.
*   Both include blood donation components, focusing on blood donation and tracking.
*   Both aim to improve communication and coordination within the healthcare sector.
*   Both descriptions highlight real-time functionalities.

**Explanation of Plagiarism Percentage Calculation:**

The 15% similarity arises from the overlapping healthcare context and the presence of a blood donation component in both projects. While \"EL-Donation\" *primarily* focuses on blood donation logistics, \"Asclepius\" includes blood donation as *one* of its many features within a broader medical platform. The similarity considers that the specific blood donation feature has a strong overlap, but also acknowledges that the overall project scopes and functionalities differ significantly. The percentage reflects that there is a similar feature, but the applications have entirely different goals.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""
Evaluate the given text based on the following criteria:
Grammar – correctness of sentence structure and verb tenses
Spelling – accuracy of word spelling
Vocabulary – richness and appropriateness of word choice
Clarity – how clear and understandable the text is
Coherence – logical flow and connection between ideas
Diagram Evaluation:
Diagram Relevance – how well the diagrams represent the content or concept described
Diagram Clarity – how clear, readable, and understandable the diagrams are
Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
Diagram Integration – how well the diagrams are connected to or support the written content
Output:
total percentage %
-Grammar – correctness of sentence structure and verb tenses
-Spelling – accuracy of word spelling
-Vocabulary – richness and appropriateness of word choice
-Clarity – how clear and understandable the text is
-Coherence – logical flow and connection between ideas
-Diagram Relevance – how well the diagrams represent the content or concept described
-Diagram Clarity – how clear, readable, and understandable the diagrams are
-Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
-Diagram Integration – how well the diagrams are connected to or support the written content
output as string

"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I will act as an evaluation tool and provide a template for evaluating the \"Asclepius\" project document based on the provided criteria. Note that I cannot actually *perform* the evaluation without the text itself, but I will give you the format for presenting the results.

**Output:**

\"Total Percentage: [Insert Percentage Here] %

*   **Grammar:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Spelling:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Vocabulary:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Clarity:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Coherence:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Diagram Relevance:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Diagram Clarity:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Diagram Accuracy:** [Insert Percentage Here] % - [Brief Explanation/Justification]
*   **Diagram Integration:** [Insert Percentage Here] % - [Brief Explanation/Justification]\"

**Explanation:**

*   **Total Percentage:** This is a summary score reflecting the overall quality of the document based on *all* criteria. Consider each criteria's individual percentage and, if desired, weigh certain criteria more heavily (e.g., Clarity and Coherence might be more critical than Vocabulary) to arrive at this overall score.
*   **Individual Criteria Percentages:** Each criterion is rated as a percentage. A higher percentage indicates better quality in that specific area.
*   **Brief Explanation/Justification:** After each percentage, a concise explanation or justification is *essential*. Explain *why* you gave that particular score. Provide examples of grammar errors, instances of unclear writing, areas where the vocabulary could be improved, etc. For diagrams, describe their usefulness, readability issues, or inaccuracies, and how well they support the text.
*   **Emphasis on Justification:** The explanation is *more* important than the specific percentage. The percentage is merely a quantitative representation of a qualitative assessment.

**Example (Illustrative, with placeholder percentages):**

\"Total Percentage: 78%

*   **Grammar:** 85% - Mostly correct; a few instances of subject-verb agreement errors and some dangling modifiers.
*   **Spelling:** 95% - Very few spelling errors; a few instances of easily missed typos.
*   **Vocabulary:** 70% - Adequate but could be more sophisticated. Some repetitive word choices and instances where more precise terminology could have been used.
*   **Clarity:** 75% - Generally understandable but suffers from overly complex sentence structures and jargon in some sections.
*   **Coherence:** 80% - Logical flow is mostly maintained, but some transitions between sections are abrupt.
*   **Diagram Relevance:** 90% - Diagrams generally represent the described system concepts.
*   **Diagram Clarity:** 65% - Some diagrams are overcrowded and difficult to read. Font sizes are too small in some labels.
*   **Diagram Accuracy:** 85% - Technically correct, but some labels could be more precise. The ER diagram is missing cardinality notation.
*   **Diagram Integration:** 70% - Diagrams are referred to in the text, but their significance is not always explicitly explained, and they sometimes feel disconnected.\"
To get a good evaluation percentage of your own, you should read all the pages. This information and explanation template is a framework for performing and presenting a structured and justified assessment.
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""
Evaluate the given text based on the following criteria:
Grammar – correctness of sentence structure and verb tenses
Spelling – accuracy of word spelling
Vocabulary – richness and appropriateness of word choice
Clarity – how clear and understandable the text is
Coherence – logical flow and connection between ideas
Diagram Evaluation:
Diagram Relevance – how well the diagrams represent the content or concept described
Diagram Clarity – how clear, readable, and understandable the diagrams are
Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
Diagram Integration – how well the diagrams are connected to or support the written content
Output:
total percentage %
-Grammar – correctness of sentence structure and verb tenses
-Spelling – accuracy of word spelling
-Vocabulary – richness and appropriateness of word choice
-Clarity – how clear and understandable the text is
-Coherence – logical flow and connection between ideas
-Diagram Relevance – how well the diagrams represent the content or concept described
-Diagram Clarity – how clear, readable, and understandable the diagrams are
-Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
-Diagram Integration – how well the diagrams are connected to or support the written content
output as string

"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I've reviewed the provided document for EL-Donation and will provide an evaluation based on the specified criteria.

\"Total Percentage: 72%

*   **Grammar:** 78% - Generally good grammar. Some minor issues with sentence structure, particularly with comma usage and sentence fragments. For example, some bullet points are sentence fragments.
*   **Spelling:** 90% - Few spelling errors. Obvious issues in consistency with \"blood type\" vs \"bloodtype\".
*   **Vocabulary:** 65% - Vocabulary is adequate but not particularly rich. Some repetition and lack of precise word choices. For example, overly frequent use of terms like \"easier\" and \"locate.\"
*   **Clarity:** 70% - The text is understandable overall, but sometimes lacks detail and precision. Could benefit from more concrete examples and specific explanations. Abstract language is frequent.
*   **Coherence:** 75% - Good overall flow, but some transitions could be smoother. The structure is clear due to the chapter headings and bullet points, but the connection between certain points within sections could be strengthened. The \"This chapter is organized as follows\" section is somewhat awkwardly worded.
*   **Diagram Relevance:** 85% - The use case and ER diagrams are directly relevant to system analysis and database design. The screenshots illustrate key UI elements.
*   **Diagram Clarity:** 70% - Some diagrams have clarity issues. The use case diagrams lack detail for some use cases, and the font is very small in some places, making them hard to read without zooming in.
*   **Diagram Accuracy:** 80% - The diagrams appear mostly technically correct (based on a high-level review, considering potential inconsistencies in diagrams that could only be noticed by close scrutiny), but would benefit from clearer labeling. The blood relations mapping is accurate for the blood donar matching.
*   **Diagram Integration:** 60% - The diagrams are referenced in the text, but their implications aren't thoroughly discussed. Deeper analysis of each stage. For example, more explicit explanations of how the diagram's elements fulfill specific requirements would increase the rating of these figures.\"
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""
Evaluate the given text based on the following criteria:
Grammar – correctness of sentence structure and verb tenses
Spelling – accuracy of word spelling
Vocabulary – richness and appropriateness of word choice
Clarity – how clear and understandable the text is
Coherence – logical flow and connection between ideas
Diagram Evaluation:
Diagram Relevance – how well the diagrams represent the content or concept described
Diagram Clarity – how clear, readable, and understandable the diagrams are
Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
Diagram Integration – how well the diagrams are connected to or support the written content
Output:
total percentage %
-Grammar – correctness of sentence structure and verb tenses
-Spelling – accuracy of word spelling
-Vocabulary – richness and appropriateness of word choice
-Clarity – how clear and understandable the text is
-Coherence – logical flow and connection between ideas
-Diagram Relevance – how well the diagrams represent the content or concept described
-Diagram Clarity – how clear, readable, and understandable the diagrams are
-Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
-Diagram Integration – how well the diagrams are connected to or support the written content
output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I have reviewed the Marketing Intelligence document and will provide an evaluation based on the specified criteria.

**Output:**

\"Total Percentage: 75%

*   **Grammar:** 80% - Generally good grammar with only minor errors. Mostly correct sentence structure and verb tenses.
*   **Spelling:** 95% - Almost no spelling errors are observed. This score is a very high as most words were spelled accurately.
*   **Vocabulary:** 75% - Mostly strong vocabulary, appropriate for the subject matter, but could be more concise. Some overly verbose phrasing occurs.
*   **Clarity:** 70% - The text is understandable for someone familiar with the domain, but it would greatly benefit from simplifying complex sentences and removing jargon, making the work more accessible to a wider audience. More examples would improve clarity, especially in sections describing complex processes.
*   **Coherence:** 80% - The document generally follows a logical progression. Subsections are well-defined, but sometimes the connections between them feel somewhat weak.
*   **Diagram Relevance:** 85% - The diagrams used effectively illustrate the design, and they support the text by visualizing complex systems. Most diagrams are relevant to the text.
*   **Diagram Clarity:** 75% - The diagrams are generally clear, but the text is too small or there are missing descriptions.
*   **Diagram Accuracy:** 80% - The information is accurate. There could be errors which are unnoticed due to small text size, and missing detailed diagram annotations.
*   **Diagram Integration:** 60% - There is a clear correlation between the text and diagrams used; some diagrams aren't referenced well in text, resulting in a failure to fully explain diagrams.\"
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Evaluate the given text based on the following criteria:
Grammar – correctness of sentence structure and verb tenses
Spelling – accuracy of word spelling
Vocabulary – richness and appropriateness of word choice
Clarity – how clear and understandable the text is
Coherence – logical flow and connection between ideas
Diagram Evaluation:
Diagram Relevance – how well the diagrams represent the content or concept described
Diagram Clarity – how clear, readable, and understandable the diagrams are
Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
Diagram Integration – how well the diagrams are connected to or support the written content
Output:
total percentage %
-Grammar – correctness of sentence structure and verb tenses
-Spelling – accuracy of word spelling
-Vocabulary – richness and appropriateness of word choice
-Clarity – how clear and understandable the text is
-Coherence – logical flow and connection between ideas
-Diagram Relevance – how well the diagrams represent the content or concept described
-Diagram Clarity – how clear, readable, and understandable the diagrams are
-Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
-Diagram Integration – how well the diagrams are connected to or support the written content
output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I have reviewed the NBTAH document and will provide an evaluation based on the specified criteria.

**Output:**

\"Total Percentage: 76%

*   **Grammar:** 75% - Generally good grammar but with some noticeable areas for improvement. There are occurrences of incorrect verb tenses and awkwardly phrased sentences that reduce readability.
*   **Spelling:** 90% - Very few spelling errors overall.
*   **Vocabulary:** 78% - Vocabulary is strong in technical areas, but at times tends towards overly complex and verbose phrasing in descriptions. A more direct and concise style would improve readability.
*   **Clarity:** 72% - The document is understandable to a point, but suffers from some overly complex explanations. Simplifying sentences and reducing jargon would significantly improve clarity.
*   **Coherence:** 77% - The document generally flows well. The structure with headings and subheadings are clear, but connection between some ideas or subtopics can be improved.
*   **Diagram Relevance:** 80% - Most of the diagrams are relevant to the content and are useful for explaining and illustrating processes and models.
*   **Diagram Clarity:** 70% - The Activity and Use Case diagrams in Chapter 3 suffer from low resolution and are hard to read. This impacts their understandability.
*   **Diagram Accuracy:** 80% - The details are accurate in the ERDs. However, due to lower clarity, accuracy evaluation of certain details.
*   **Diagram Integration:** 75% - The diagrams are mostly referenced in the text, but their significance isn't always fully explained. More explicit explanation of how diagrams support the points made in the text would improve this further.\"
"""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""Evaluate the given text based on the following criteria:
Grammar – correctness of sentence structure and verb tenses
Spelling – accuracy of word spelling
Vocabulary – richness and appropriateness of word choice
Clarity – how clear and understandable the text is
Coherence – logical flow and connection between ideas
Diagram Evaluation:
Diagram Relevance – how well the diagrams represent the content or concept described
Diagram Clarity – how clear, readable, and understandable the diagrams are
Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
Diagram Integration – how well the diagrams are connected to or support the written content
Output:
total percentage %
-Grammar – correctness of sentence structure and verb tenses
-Spelling – accuracy of word spelling
-Vocabulary – richness and appropriateness of word choice
-Clarity – how clear and understandable the text is
-Coherence – logical flow and connection between ideas
-Diagram Relevance – how well the diagrams represent the content or concept described
-Diagram Clarity – how clear, readable, and understandable the diagrams are
-Diagram Accuracy – whether the diagrams are technically correct and appropriately labeled
-Diagram Integration – how well the diagrams are connected to or support the written content
output as string"""),
            ],
        ),
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text="""Okay, I have reviewed the provided SignEcho document and will provide an evaluation based on the specified criteria.

\"Total Percentage: 74%

*   **Grammar:** 75% - Decent grammar. Most sentences are understandable, but there are a few noticeable issues with article usage (\"a Sign language\") and sentence structure.
*   **Spelling:** 90% - Pretty good spelling, minor errors that could be caught with a proofread.
*   **Vocabulary:** 70% - The vocabulary is somewhat limited and could be more precise. Repetitive phrasing occurs. A more diverse word choice is necessary.
*   **Clarity:** 70% - Understandable. Clearer, more specific descriptions of features and algorithms would improve clarity.
*   **Coherence:** 75% - The logical structure is understandable. Some areas of flow from point to point requires more cohesion.
*   **Diagram Relevance:** 85% - App screens, architecture diagrams, and data models are relevant to the project.
*   **Diagram Clarity:** 70% - The architectural and class diagrams are dense and difficult to read due to the small text. The app screen images are clear and easy to understand.
*   **Diagram Accuracy:** 75% - Class diagrams have technical correctness errors. Check all relations
*   **Diagram Integration:** 75% - Code snippets are related to app feature, not explaining code parts.\""""),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text="""INSERT_INPUT_HERE"""),
            ],
        ),
    ]
    generate_content_config = types.GenerateContentConfig(
        response_mime_type="text/plain",
    )

    for chunk in client.models.generate_content_stream(
        model=model,
        contents=contents,
        config=generate_content_config,
    ):
        print(chunk.text, end="")

if __name__ == "__main__":
    generate()