from prefect import flow, task


@task(log_prints=True)
def say_hello(name):
    print(f"hello {name}")


@task(log_prints=True)
def say_goodbye(name):
    print(f"goodbye {name}")


@flow(name="say hello and goodbye")
def greetings(names=["arthur", "trillian", "ford", "marvin"]):
    for name in names:
        say_hello(name)
        say_goodbye(name)
