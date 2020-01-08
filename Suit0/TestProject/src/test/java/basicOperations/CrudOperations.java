package basicOperations;

import org.testng.annotations.Test;
import org.testng.AssertJUnit;
import org.json.simple.JSONObject;
import org.testng.Assert;
import org.testng.annotations.Test;

import io.restassured.RestAssured;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;

public class CrudOperations {
	
	String url = "http://localhost:9090/company/";
	JsonPath jsonPathEvaluator;
	
	@Test(priority = 0)
	public void testWriteFile()
	{
		RequestSpecification request = RestAssured.given();
		request.header("Content-Type", "application/json");
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("firstName", "John");
		jsonObject.put("lastName", "Doe");
		jsonObject.put("age", 21);
		jsonObject.put("gender", "M");
		
		request.body(jsonObject.toJSONString());
		Response response = request.post(url+"addJsonFile");
		
		jsonPathEvaluator = response.jsonPath();
		String message = jsonPathEvaluator.get("Message");
		
		AssertJUnit.assertEquals(message, "Employee records uploaded successfully.");
		AssertJUnit.assertEquals(response.getStatusCode(), 200);
	}
	
	@Test(priority = 1)
	public void testGetAction()
	{
		String fileName = "account.json";
		Response response = RestAssured.get(url+"readFile/"+fileName);
		String expected = "{\"firstName\":\"John\", \"lastName\":\"Doe\", \"gender\":\"M\", \"age\":21}";

		AssertJUnit.assertEquals(response.asString(), expected);
		AssertJUnit.assertEquals(response.getStatusCode(), 200);
	}
	
	@Test(priority = 2)
	public void testRenameFile()
	{
		String fileName = "RenamedFile.json";
		Response response = RestAssured.get(url+"renameFile/"+fileName);
		
		jsonPathEvaluator = response.jsonPath();
		String message = jsonPathEvaluator.get("Message");

		AssertJUnit.assertEquals(message, "The file is renamed successfully.");
		AssertJUnit.assertEquals(response.getStatusCode(), 200);
	}
	
	@Test(priority = 3)
	public void testDeleteFile()
	{
		String fileName = "RenamedFile.json";
		Response response = RestAssured.delete(url+"deleteFile/"+fileName);
		
		jsonPathEvaluator = response.jsonPath();
		String message = jsonPathEvaluator.get("Message");

		AssertJUnit.assertEquals(message, "Employee records deleted successfully.");
		AssertJUnit.assertEquals(response.getStatusCode(), 200);
	}

	@Test(priority = 4)
	public void testCreateFolder()
	{
		String folderName = "DMajor";
		Response response = RestAssured.get(url+"createFolder/"+folderName);
		
		jsonPathEvaluator = response.jsonPath();
		String message = jsonPathEvaluator.get("Message");

		AssertJUnit.assertEquals(message, "The folder is created successfully.");
		AssertJUnit.assertEquals(response.getStatusCode(), 200);
	}
	
	@Test(priority = 5)
	public void testRemoveFolder()
	{
		String folderName = "DMajor";
		Response response = RestAssured.get(url+"removeFolder/"+folderName);
		
		jsonPathEvaluator = response.jsonPath();
		String message = jsonPathEvaluator.get("Message");

		AssertJUnit.assertEquals(message, "The folder is deleted successfully.");
		AssertJUnit.assertEquals(response.getStatusCode(), 200);
	}
	
}
