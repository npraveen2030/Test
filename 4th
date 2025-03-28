using System;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

public class DataTableHelper
{
    private readonly AppDbContext _context;

    public DataTableHelper(AppDbContext context)
    {
        _context = context;
    }

    public DataTable ConvertQueryToDataTable(string sqlQuery)
    {
        // Execute the query with raw SQL.
        var results = _context.Users.FromSqlRaw(sqlQuery).ToList();  // Using LINQ or raw SQL

        // Create an empty DataTable.
        DataTable dataTable = new DataTable();

        // Use reflection to get the properties of the object returned by the query.
        if (results.Count > 0)
        {
            var properties = results.First().GetType().GetProperties();

            // Add columns to DataTable based on the properties.
            foreach (var prop in properties)
            {
                dataTable.Columns.Add(prop.Name, prop.PropertyType);
            }

            // Add rows to the DataTable.
            foreach (var result in results)
            {
                var values = properties.Select(p => p.GetValue(result, null)).ToArray();
                dataTable.Rows.Add(values);
            }
        }

        return dataTable;
    }

    // Example of calling the method
    public void RunExample()
    {
        string query = "SELECT * FROM Users WHERE Age > 30"; // Example dynamic query
        DataTable dt = ConvertQueryToDataTable(query);

        // Optionally, display the contents of the DataTable for testing
        foreach (DataRow row in dt.Rows)
        {
            foreach (var item in row.ItemArray)
            {
                Console.Write(item + "\t");
            }
            Console.WriteLine();
        }
    }
}

public class AppDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
}
