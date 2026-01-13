# Flyway Quests - Your Learning Journey

## 🎯 About Flyway Quests

**Flyway Quests** are your hands-on learning companion for mastering Flyway in real-world scenarios. Whether you're coming from a Flyway Autopilot POC, rolling out Flyway to your organization, or simply want to level up your database DevOps skills, these quests provide practical, scenario-based learning.

### 🔄 Quests vs. Flyway Autopilot

**Flyway Autopilot** gets you started - it sets up your environment, creates sample databases, and gives you a ready-to-use project with version control and CI/CD pipelines configured.

**Flyway Quests** take you further - they're your ongoing learning journey to master Flyway workflows, test real-world scenarios, and build confidence using the tool in your daily work.

> 💡 **Use Quests standalone or after Autopilot** - whether you're in POC phase, rollout, or ongoing operations, these quests help you learn by doing.

---

## 📁 Quest Categories

### 👨‍💻 Development
**Focus:** Daily workflows for developers working with database changes

Learn how to capture changes, work with branches, synchronize with your team, and manage version control alongside your SQL development work. These quests mirror real development workflows, not just SQL exercises.

### 🔧 Operations  
**Focus:** Deployment workflows, validation, and production releases

Master the deployment side of CI/CD - from validating changes before production to deploying via GUI and CLI. Learn safety checks, pipeline integration, and operational best practices.

### 🧪 Scenarios
**Focus:** Testing how Flyway handles different database objects and situations

Create and test various database scenarios - stored procedures, constraints, cross-schema references, triggers, and more. Perfect for exploring "what if" situations during POCs or validating Flyway behavior for your specific needs.

---
## 🚀 Getting Started

### How to Choose a Quest

**Pick by what you need to learn, not by order!** Each quest is self-contained:

**New to Flyway?**
- Start with `Development/Capture-New-Changes` to learn the basics
- Then try `Development/Static-Data` to handle reference data

**Working in a team?**
- `Development/Merging-Changes` shows how to handle concurrent development

**Setting up CI/CD and want to learn the CLI?**
- `Operations` teaches deployment through the CLI, and automating safely.

**Testing scenarios during POC?**
- Explore `Scenarios/` to see how Flyway handles different database objects

### Prerequisites

- **Flyway Desktop** installed and licensed (Enterprise or trial)
- **Sample database** set up via Flyway Autopilot or manually
- **Git repository** configured (for Development quests)
- **Azure DevOps** pipeline access (for Operations quests only)
- **SQL Server Management Studio** or Azure Data Studio (optional but helpful)

### Quest Structure

Each quest folder contains:
- 📄 **{QuestName}.md** - Step-by-step guide with explanations
- 📄 **{QuestName}.sql** - Setup script to create the scenario (Sometimes this wont exist and all is managed through MD)

**Always run the .sql file first!** It creates the tables, data, or scenario you'll be working with.

Every quest guide includes:
- 🎯 **Learning Objectives** - What you'll master
- 📖 **Scenario** - Real-world context
- 📝 **Steps** - Clear, actionable instructions  
- 💡 **Code Examples** - Copy-paste ready SQL
- ✅ **Success Criteria** - How to validate you've succeeded
- 🐛 **Troubleshooting** - Common issues and fixes
- 🚀 **Advanced Challenges** - Optional extensions (where applicable)

---

## 💡 Tips for Success

### Best Practices ✅
- **Run the SQL setup script first** - Every quest includes a .sql file to set up the scenario
- **Take your time** - Understanding beats speed
- **Read hints sections** - They contain valuable context
- **Try advanced challenges** - Deepen your learning
- **Test as you go** - Validate each step before moving on

### Common Pitfalls ❌
- Don't skip the prerequisites
- Don't rush through scenarios without understanding
- Don't ignore error messages - they're learning opportunities
- Don't be afraid to experiment - you have sample databases for a reason

---

## 🏆 Quest Difficulty Guide

🟢 **Beginner** - New to Flyway, comfortable with SQL basics  
🟡 **Intermediate** - Familiar with Flyway concepts, ready for real workflows  
🔴 **Advanced** - Experienced with Flyway, exploring edge cases or complex scenarios

---

## 🆘 Need Help?

If you get stuck:

1. **Check the quest's Hints section** - Most common issues are covered
2. **Review Troubleshooting** - Every quest includes troubleshooting guidance
3. **Consult official docs** - [Flyway Documentation](https://documentation.red-gate.com/flyway)
4. **Flyway Helper Files** - See [RG-AutoPilot/Flyway-Helper-Files](https://github.com/RG-AutoPilot/Flyway-Helper-Files) for CLI examples
5. **Ask your team** - Share knowledge with colleagues

---

## 📞 Feedback & Contributions

Found an issue? Have a scenario to add?

- Open an issue in the repository
- Submit a pull request with improvements
- Suggest new quest scenarios based on your POC experiences

**Quest ideas we'd love to see:**
- Real scenarios you encountered during POCs
- Complex database patterns specific to your industry
- Edge cases that tested Flyway's capabilities

---

## 🎯 Remember

**Flyway Autopilot** gets you started with setup and configuration.

**Flyway Quests** build your confidence and skills through hands-on practice.

**Your experience** determines when and which quests you need - there's no "right" path, only the path that matches your learning goals.

---

**Happy Learning!** 🚀

*Choose a quest, run the setup script, and start building your Flyway expertise.*

