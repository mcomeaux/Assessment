using System;
using System.IO;
using System.Linq;
using System.Reflection;
using DbUp;
using DbUp.Engine;
using DbUp.Helpers;
using DbUp.Support;
using Microsoft.Extensions.Configuration;

namespace Assessment.DbUpdater
{
    class Program
    {
        static int Main(string[] args)
        {

            IConfiguration config = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: false)
                .AddEnvironmentVariables()
                .AddCommandLine(args)
                .Build();

            var variables = config
                .GetSection("variables")
                .GetChildren()
                .ToDictionary(x => x.Key, x => x.Value);

            Console.ForegroundColor = ConsoleColor.White;
            Console.WriteLine("===Variables===");
            foreach (var variable in variables)
            {
                Console.ForegroundColor = ConsoleColor.Gray;
                Console.Write($"{variable.Key}=");

                Console.ForegroundColor = ConsoleColor.White;
                Console.WriteLine(variable.Value);

            }

            var environment = variables["Environment"];
            var connectionString = config.GetConnectionString(environment);

            Console.WriteLine($"ConnectionString={connectionString}");

            var predeployUpgrader = DeployChanges.To
                .SqlDatabase(connectionString, null)
                .WithVariables(variables)
                .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), x => x.StartsWith("DbUpdater.PreDeployment."))
                .WithTransactionPerScript()
                .JournalTo(new NullJournal())
                .LogToConsole()
                .Build();

            var upgrader = DeployChanges.To
                .SqlDatabase(connectionString, null)
                .WithVariables(variables)
                .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), x => x.StartsWith("DbUpdater.Migrations."))
                .WithTransactionPerScript()
                .JournalToSqlTable("dbo", "SchemaVersions")
                .LogToConsole()
                .Build();

            var postdeployUpgrader = DeployChanges.To
                .SqlDatabase(connectionString, null)
                .WithVariables(variables)
                .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), x => x.StartsWith("DbUpdater.PostDeployment."))
                .WithTransactionPerScript()
                .JournalTo(new NullJournal())
                .LogToConsole()
                .Build();

            if (environment == "DEV")
            {
                EnsureDatabase.For.SqlDatabase(connectionString);
            }

            Console.WriteLine("Is upgrade required: " + upgrader.IsUpgradeRequired());

            if (args.Any(a => a.StartsWith("--WhatIf", StringComparison.InvariantCultureIgnoreCase)))
            {
                foreach (var script in upgrader.GetScriptsToExecute())
                {
                    Console.WriteLine($"{script.SqlScriptOptions.ScriptType} {script.SqlScriptOptions.RunGroupOrder} {script.Name}");
                }
            }
            else if (args.Any(a => a.StartsWith("--MarkAsExecuted", StringComparison.InvariantCultureIgnoreCase)))
            {
                var result = upgrader.MarkAsExecuted();
                // Display the result
                if (result.Successful)
                {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine("Success!");
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine(result.Error);
                    Console.WriteLine("Failed!");
                }


            }
            else if (args.Any(a => a.StartsWith("--PreviewReportPath", StringComparison.InvariantCultureIgnoreCase)))
            {
                // Generate a preview file so Octopus Deploy can generate an artifact for approvals
                var report = args.FirstOrDefault(x => x.StartsWith("--PreviewReportPath", StringComparison.OrdinalIgnoreCase));
                report = report.Substring(report.IndexOf("=") + 1).Replace(@"""", string.Empty);

                var fullReportPath = Path.Combine(report, "UpgradeReport.html");

                Console.WriteLine($"Generating the report at {fullReportPath}");

                upgrader.GenerateUpgradeHtmlReport(fullReportPath);
            }
            else
            {

                if (!UpgradeAndLog(predeployUpgrader, environment))
                {
                    return 1;  //Failed on 1st step.  Pre-deployment scripts
                }

                if (!UpgradeAndLog(upgrader, environment))
                {
                    return 2;  //Failed on 2nd step.  Migrations scripts
                }

                if (!UpgradeAndLog(postdeployUpgrader, environment))
                {
                    return 3;  //Failed on 3rd step.  Post-deploymnent scripts
                }

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("Success!");
                Console.ResetColor();
            }
            return 0;
        }
        private static bool UpgradeAndLog(UpgradeEngine upgrader, string environment)
        {
            var result = upgrader.PerformUpgrade();
            if (environment != "DEV")
            {
                result.WriteExecutedScriptsToOctopusTaskSummary();
            }
            if (!result.Successful)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(result.Error);
                Console.ResetColor();
                return false;
            }
            return true;
        }
    }
}
