import httpx
import time
from prefect import flow, task


@task(log_prints=True)
def get_stars_for_repo(repo: str) -> int:
    response = httpx.Client().get(f"https://api.github.com/repos/{repo}")
    stargazer_count = response.json()["stargazers_count"]
    print(f"{repo} has {stargazer_count} stars")
    return stargazer_count


@task(log_prints=True)
def print_stars(stars: int) -> None:
    time.sleep(180)
    print(f"Total stars: {stars}")


@flow
def retrieve_github_stars(repos: list[str]) -> list[int]:
    all_stars = get_stars_for_repo.map(repos).wait()
    print_stars(all_stars)
