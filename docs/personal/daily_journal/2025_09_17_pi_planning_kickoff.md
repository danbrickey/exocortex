Brain dump, September 17, 2025. 
Most of my time this day was involved in PI planning week, which started today. Next Wednesday will be the beginning of our PI. This week is about planning and writing features and stories with acceptance criteria, at least a couple of sprints into the future. At least covering the first couple of features that are in the PI. 

So EDP teams are changing, And I am no longer on an individual contributor team, but I am still working with individual teams to help plan the PI. I am on a new team that is tasked with business alignment. This new team is mostly solution architects. Looks like I'll still have solution archtecture responsibilities with oversight on environment changes and code repository moves and so on with other EDP data engineering teams. In addition, I need to finish modeling the member and product domains as we work with the business, and continue feeding that works to the off shore engineering team. So maybe by the end of the PI, we will have provider, product, and member raw vaults all built out, Or at least modeled. . And be working toward business vault definitions. In EDW2 terms, this is:
1. Member coverage
2. Member eligibility
3. Provider
4. Maybe claims. 
5. Maybe a new product factor

Besides helping plan PI features and stories, I met with some of the data engineering teams to discuss the switch from Rising Sun to North Star. And also the changes we need to make to have a real-time (near real-time) set of data pipelines. The plan is that we consolidate our environment to a single Snowflake account with a dev, test, prod, and perhaps UAT environments. That's the sort of end of the PI future state. The transition is:
1. We move our dbt code repositories and point them at the existing Franken environment in the Northstar account.
2. We split the code repository for the One View app (use case that has the near real-time requirements). 
3. Then the OneView app is freed up to make performance increases and tuning and simplify their pipelines and not be dependent on all of the analytical workloads to complete loading before they have their data. 
4. The goal for the One View app is to have less than 5 minutes of latency (that's the proposed goal). The business has not signed off on it, but we're going to get as close as we can. 
5. The source source dbt project, which contains both raw layer and hcdm sources, needs to be migrated as well. 
6. The Data Domains DBT project, which handles the analytical workloads, Needs to migrate over to Frank as well. 
7. Once all of our data engineering work in dbt is happening on the Franken environment, we can decommission Rising Sun and start working on the new dev environment that will be in North Star. Without disrupting ongoing development by the data engineering teams. 
8. Then we can test side-by-side, the dev environment and the temporary Franken environment that we will be doing development in on North Star until the dev environment looks good and usable. And then we can flip the switch and migrate to using that for our development activities. 

The reason we're doing a soft switch instead of just taking the leap is that there is a bunch of RBAC changes coming and we expect some disruption because of that. Having to fiddle around with permissions and so on in the new environments before we can actually start developing there. We have also discussed just renaming the Franklin environment to dev, however, I think we're leaning away from that at the moment because of the risk of bringing all of our poor decisions over the last two years with us. So, I think everybody is feeling like we just want to start fresh, clean slate, and build it from there. 

On the solution architecture front, I will need to set up some meetings along with data governance and Lindsay to help them meet with the business and start putting together a data council to drive these data products that we're working on that are based on business context domains. This part is where I think the data domain-driven design is going to help us create a shared vocabulary. I need to work on some diagrams that break down how the domain-driven design works and maybe a presentation layer that I can share with the business that's not too technical. 

