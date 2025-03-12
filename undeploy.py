import asyncio
from prefect.client.orchestration import get_client, PrefectClient


async def undeploy():
    print("Undeploying all deployments")
    client: PrefectClient = get_client()
    deployments = await client.read_deployments()

    async for deployment in deployments:
        name = deployment.entrypoint.split(":")[-1]
        print(f"Deleting deployment {name}")
        await client.delete_deployment(str(deployment.id))


if __name__ == "__main__":
    asyncio.run(undeploy())
