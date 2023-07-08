# Shell_Script_run_multiple_ruby


If you want to run all the Ruby services at once, you can modify the script to include an additional option to start all services. Here's an updated version of the script with the new option:



```bash
./ruby_services.sh start all
```

Similarly, you can stop all services at once with:

```bash
./ruby_services.sh stop all
```

And to restart all services at once:

```bash
./ruby_services.sh restart all
```

The `status` command will continue to work as before, showing the status of individual services or all services if no service names are provided.
