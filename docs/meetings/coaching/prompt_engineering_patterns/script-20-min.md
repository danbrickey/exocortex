# **Intro**

How many of you have spent an hour arguing with ChatGPT only to get code that doesn't compile, a terrible diagram, or a robotic generic sounding response? There are techniques that can get you out of that adversarial role with AI and into the results you want. And they can get you there more quickly and repeatabley. 

If you have been following AI news, blogs, prompting guides, et cetera for the last few months, you may already be familiar with some of these techniques. But hopefully, there will still be something useful in here. You can find a full write-up with explanations and examples in Confluence if you want text and examples. There are several more of these techniques in that guide. Alternatively, if you have some techniques that you use that are not on this list, please share them. They're probably useful to others as well. The Confluence link to the write-up will be in the slide deck, but if you have trouble getting to it, let me know. 

I think of AI Models as if they are a team of very well-educated interns who work quickly and almost for free but they're all very naive, they're a little forgetful and they are inexperienced. Could you take a team like that and hand them instructions so that they could pause plausibly do a good job with the task? If you think you could do that, then you should be able to hand those same instructions to an AI. AI needs that same amount of instruction. The context of our company, the audience involved, examples of good work, standards documents, and unique technical constraints are all things that we need to educate the AI in. If those aren't part of your prompt or your context, then the AI is going to struggle to do the task you are giving it. 

So if you can't describe the work clearly enough to write it down in a structured way and give it to our team of bright helpful interns, the AI model doesn't really have a chance to do that task successfully. 

As AI progresses and the work it is capable of doing evolves, we see patterns emerging that can help models understand your prompt. These communication patterns that work with LLMs will continue to evolve alongside AI capability, but they are beginning to feel a little more like durable engineering patterns with semi-official names that the industry is starting to agree on.

# **Breakdown**
These AI prompting techniques fit into a few different categories. 

* Self-Correction Systems (having the model catch its own mistakes)
* Meta-Prompting (using AI to improve prompts themselves)
* Reasoning Scaffolds (forcing the model to do deeper analysis)
* Perspective Engineering (having the model surface blind spots in analysis)
* Specialized Tactics (handling model constraints)
* Creative and Exploratory Techniques (having the model generate new ideas)

# **Self-Correction and Iterative Refinement**
This tier of techniques forces the model to find and fix its own errors before delivering a final answer, breaking the cycle of committing to a single, potentially flawed reasoning path.

**Adversarial Prompting**
- This technique is an aggressive form of self-correction. Adversarial prompting demands that the model actively attack its own output to find problems, even if it has to "stretch" its reasoning to do so. It exploits the model's tendency to comply with instructions, forcing the consideration of edge cases and failure modes that a standard review might miss.
- Here's an example:
"Attack your previous response. Identify five specific ways it could be compromised, bypassed, or fail under adversarial conditions. For each vulnerability, assess likelihood and impact, then propose revisions."
- When to Use This:
    - High-stakes scenarios where the cost of error is significant
    - Security design and risk assessment
    - Strategy recommendations

# **Meta-Prompting (AI-Assisted Prompt Engineering)**
This tier of techniques exploits the model's meta-knowledge, as it has been trained on countless discussions, papers, and templates about effective prompt engineering.

**Reverse Prompting**
- Purpose: Reverse prompting solves the problem of not knowing how to structure a prompt for an unfamiliar or complex task. Instead of guessing, you ask the model to design the optimal prompt for achieving your goal and then immediately execute it. This technique exploits the model's meta-knowledge, as it has been trained on countless discussions, papers, and templates about effective prompt engineering.
- Here's an example:
“You are an expert prompt engineer. Design the single most effective prompt to analyze quarterly earnings reports for early warning signs of financial distress. Consider what details matter, what output format is most actionable, what reasoning steps are essential. Then execute that prompt on this Q3 report.”
- When to Use This:
    - Unfamiliar domains where you're not sure what an optimal prompt looks like
    - Complex analysis tasks

**Recursive Prompt Optimization**
* Purpose: This technique is used to harden prompts that will be used repeatedly, such as in production systems or shared libraries. It's a structured process where you instruct the model to refine a prompt through multiple iterations to add constraints, resolve ambiguities, and enhance its depth.
* How it Works: You provide a simple starting prompt and ask the model to improve it through structured refinement. For example, a basic prompt like "Answer customer questions about our product" can be recursively optimized into a highly structured, production-ready version:

“You are a customer support specialist for [product]. User question: {question}. Response requirements: First, confirm you understand the specific issue. Second, provide step-by-step solution with screenshots if applicable. Third, explain why the solution works. Fourth, offer related tips that prevent similar issues. Fifth, suggest relevant documentation. Tone: professional but warm. If question is ambiguous, ask exactly one clarifying question. If issue requires engineering intervention, clearly state this and what information to provide. Length: 150-300 words.”

* When to Use:
  * Building reusable prompts for production systems
  * Creating prompt libraries that require consistency

# **Reasoning Scaffolds (Structuring Thought)**

Once your prompt is well engineered, and you are comfortable with the fact that you have a high-quality prompt, sometimes the next step is to control how the model does its thinking. This type of technique provides a structure that changes how or guides how the model thinks, making it more thorough and systematic instead of giving it the latitude to jump to a unhelpful conclusion. 

**Zero-Shot Chain-of-Thought Prompting**

Zero-shot Chain-of-Thought prompting is a way of boosting an LLM's ability to follow complex reasoning. You don't even need specific examples for this to work which is why it's called zero-shot. Instead of examples, you give the AI reasoning steps. You guide it through the steps that you want it to take as it figures out a solution to your request. Since AIs are pattern machines at heart, what this will do is help it find the right solution patterns that match what you are after.

You could say, "You are a Root Cause Analysis Specialist 
Response Requirements: 
1. Define the scope of the problem
2. Identify the key variables involved
3. Analyze the relationships between the variables
4. Consider potential edge cases
5. Synthesize a final conclusion 
Tone: professional but warm. If question is ambiguous, ask exactly one clarifying question. If issue requires emergency actions or escalations state that clearly with next step suggestions. Length: 150-300 words." 

The limitation of zero-shot chain of thought prompting is that it puts the LLM on a specific track and it limits the comprehensiveness of its answer. If you're looking for new information, you might not get it. But if you're looking for a well defined set of steps to follow, then you can expect to get a better result using chain of thought prompting. 

* When to Use:
  * When you want to limit the 'creativity' of the model
  * When you have standard troubleshooting techniques to follow

# **Perspective Engineering (Surfacing Blind Spots)**

Perspective engineering is helping the LLM understand the point of view of the different parts of a complex decision. This is a way of getting past the tendency of an LLM to use a single sort of default point of view when it's answering a question. So we want our questions, many times, to come from a place of competing viewpoints and trade-offs that are ambiguous. 

**Multi-Persona Debate**
- Purpose: This technique is designed to surface blind spots and uncover trade-offs in complex decisions. It works by simulating a structured debate between several expert personas who have been assigned specific, genuinely conflicting priorities to create the analytical tension needed for a robust synthesis.
- How it Works:
“Simulate a debate between a cost-focused CFO, a risk-averse CISO, and a pragmatic VP Engineering... The CFO prioritizes total cost of ownership... The CISO prioritizes security posture... The VP Engineering prioritizes developer velocity... After debate, synthesize a recommendation that explicitly addresses all three concerns and explains which tradeoffs are acceptable and why.”
- When to Use: This technique should be used for complex decisions with legitimate tradeoffs where there is no single "correct" answer.

# **Specialized Tactics for Production Constraints**
This provides a practical tactic for handling a common technical constraint.This final tier contains a specific, surgical tactic for a common technical problem: hitting the context window limit in a long, complex conversation.

**Summary-Expand Loop**
- Purpose: This technique solves the problem of hitting the context window limit during a long, multi-stage analysis. It works by compressing the entire conversation into a dense summary that distills the conversation to its semantic essence. You can then start a new chat with that summary, freeing up the token budget for a deeper, more comprehensive final output.
- How it Works: The process involves two phases. First, you ask the model to create a structured summary of key findings, critical details, and open questions. Second, you copy that summary, paste it into a new conversation, and ask the model to continue the analysis or generate a final output.
- When to Use:
    ◦ Multi-stage research or deep dives that span multiple conversations
    ◦ Iterative refinement of a complex topic

# **Calibrated Confidence Prompting (CCP)**
This is a technique that forces the model to justify its answer. It's a way of making the model more accountable for its reasoning, because one of the significant challenges with LLMs is their tendency to present speculative information with the same level of confidence as well-established facts. This technique addresses this by instructing the model to assign explicit confidence levels to every claim it makes. 

An example prompt is:

"I need information about [specific topic]. When responding, for each claim you make, assign an explicit confidence level using this scale:

* Virtually Certain (>95% confidence): Reserved for basic facts with overwhelming evidence.
* Highly Confident (80-95%): Strong evidence supports this, but nuance may exist.
* Moderately Confident (60-80%): Good reasons to believe this, but significant uncertainty remains.
* Speculative (40-60%): Reasonable conjecture, but highly uncertain.

For 'Moderately Confident' or 'Speculative' claims, mention what additional information would help increase confidence."

# **Closing**
To wrap up, LLMs are, at their core, pattern-recognizing machines. They're very good at transforming text and code, mapping messy inputs to structured outputs, following explicit instructions, and doing the same thing over and over again without getting bored. 

The right question is never, "Can AI do my job?" The question to ask yourself is, "Which parts of my job are repetitive, checkable, describable, and verifiable?" And how do I turn those into workflows that an AI can run or assist with? Remember our "Team Of Interns" metaphor? 

They are NOT inherently good at making decisions with ambiguous trade-offs, they don't understand company culture, they don't know context unless you give it to them, and they don't respect boundaries you don't define. 

But if you can decompose your work into explicit steps, clear inputs, clear decision logic, and clear outputs, then you can start thinking about where AI fits, where you can leverage it (not to replace you but to handle the repetitive, boring, and checkable parts) while you focus on the judgment calls, the exceptions, and the strategy. Engineering a scalable, secure, automated process with good judgment, a human in the loop at the right points that fits the company you are working for is looking like a durable human set of skills that AI can't replace anytime soon.

The first key to this is treating your prompts like engineered code. To a large extent, the prompt is becoming part of the deliverable. I don't know if I agree with "the prompt is the new code" yet, but that is certainly the trend we can see. At minimum, a well-engineered prompt is certainly a part of the product we will be delivering in the future.  
 
# **Q&A**
Okay, we don't have much time left. But we can take that time with questions and answers if you want. 


