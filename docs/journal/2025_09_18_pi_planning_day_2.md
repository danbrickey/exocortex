Brain dump, September 18th, 2025 

# 8:30 AM  Management review and problem-solving meeting
We discussed moving our development environment from Dev in Rising Sun to Frank and environment in North Star. 
Decision which everyone agreed on was to move our Dev environment to Franken prior to creating a new Dev environment in North Star. 
It was also agreed that now is a good time to do this over the next part of planning week and the first sprint in the next PI. 
So I and the other data engineering leads will start working on the plan to move our dev activities to North Star in the Franken environment. 

# 9am Meeting with Lokendra about more raw_vault work. 
Discuss the fact that most of the raw_vault work for provider is done. We talked about the potential for doing more work in the membership domain. I'm going to build out a couple of stories in the membership domain for Lokendra and Shweta to work on. Next week, we need to talk with Shay Harding at Hakoda to make sure that this is a good direction to have Lokendra and Shweta work in. 

# 10am Edp Team One Daily Stand Up. 
Discussed creating the Jira stories for the Hakoda data engineering team, and I'm going to do that in the Hakoda team backlog. Also discussed the environment hardening efforts and the switch to a single Snowflake account. I'm going to discuss the timing and effort of the switch with the data engineering team in a data engineering forum today. And then I'll provide feedback to the architects. 

# 10:30 am Snowflake Environment Hardening Planning Meeting. 
Discuss the details around how Lakshmi's team deploys code and what their deployment pipeline looks like. They do have some ingestion work that they have done that is in the raw layer. And they have a deployment pipeline in GitLab that contains most of their code. Didn't sound like they had an enormous preference between renaming Franken or creating a brand new dev environment. Their preference was to get the work done early so it would be less disruptive to their development workflow later in the quarter. That makes me want to lean toward renaming the environment. That happens within a couple of days of the start of the PI, and then work with the admins to get the RBAC and PBAC cleaned up. 

# 11 am Planning round 3 for EDP_team_1. 
As an architecture team, we discussed the pace and options when it comes to our environment reconfiguration, as we do away with Rising Sun and move all of our development, testing, and production work into NorthStar so that we can transition Rising Sun into a proof of concept and training account with completely synthetic data. We are waiting for feedback from two different teams on what they think their timeline and effort can be to the two different approaches.
1. Approach 1: Rename the existing Franken environment to Dev. That rename would then impact everybody doing development and they would have to make all the configuration changes to their environments to adapt to that, and then they would be back on their feet. The downside here is that the admins would have their job cut out for them to make all the necessary RBAC and PBAC changes without disrupting development schedules. 
2. Approach two is to replicate the Franken environment and name the new replicated environment 'dev'. Then, clean that environment up. Remove all of the data. The data wouldn't even be cloned, just the structure. And the data would only be populated in the raw layer, and then we'd hydrate the rest of the layers from that. The downside to this approach is that the switch to dev will probably take longer, and the impact to the data engineering teams would happen later in the planning increment. And I think the development teams would prefer to have the impact up-front in the planning increment so that they can focus on their deliverables in the last half of the planning increment when things are coming due. 

# 1 pm Northstar environment transition meeting for dbt data engineers. 
- Spent the time discussing the move from Rising Sun to North Star into the Franken environment for development. 
- We discussed merging the shared develop branch up to test and UAT. If all goes well with that merge, then we will merge to main tomorrow afternoon. 
- We also talked through the possibilities of splitting our code repositories that are shared for independent use cases, such as the data extract team separated from the data domains work in curation and integration so that they're independent of the data domains teams where they schedule. The other use case where it would help is for the OneView data engineering pipelines that need to be more real-time and will have a software product, the customer service portal, driving a lot of their features and release schedules. 

## Decisions made. 
1. Merge develop into test in UAT today. 
2. We will begin the move over to Franken tomorrow afternoon in a shared group working session where I will drive and everybody else will make sure that they understand what's going on. It will be optional for the data engineers. 
3. Next week, we will begin discussing the creation of new repositories once we are into the North Star environment and have our environments all rewired. 
4. Once the Franken environment is functional, we also need to discuss the refresh of the Franken raw layer so that that environment can be used for testing up-to-date data. 

# 4:00 pm Troubleshooting session for dbt flattened table in prod. 
