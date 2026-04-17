from praisonaiagents import Agent

agent = Agent(
    name="TestAgent",
    role="Researcher", 
    instructions="你是一个AI研究助手。用简短的话回答问题。",
    model="ollama/qwen2.5:7b",
    base_url="http://localhost:11434/v1"
)

result = agent.start("你好，请用一句话介绍自己")
print("结果:", result)
