import requests
import json

class RestManager:

	URI = 'http://127.0.0.1:8080'
	password = 'test'
	Session = None
	ret_code = None

	# Setting up account information for the login
	def __init__(self, admin):
		if (admin):
			self.email = "paul_TEST@collette.io"
			print("Admin user created for testing purposes")
		else:
			self.email = "francois_TEST@collette.io"
			print("Non-Admin user created for testing purposes")

	# POST : Signin call, return a Session object stored for later API requests
	def signin(self):
		body = { "email" : self.email, "password" : self.password}
		self.Session = requests.Session()
		r = self.Session.post(self.URI + '/signin', body)
		self.ret_code = r.status_code
	
	# GET : Return the buildings linked to the user signed-on
	def buildings(self):
		r = self.Session.get(self.URI + '/buildings')
		if (r.status_code == 404):
			print(r.content)
			print(r.headers)
		self.ret_code = r.status_code
		return r.content
	
	# GET : Return the tickets linked to the user signed-on
	def tickets(self):
		r = self.Session.get(self.URI + '/tickets')
		if (r.status_code == 404):
			print(r.content)
			print(r.headers)
		self.ret_code = r.status_code
		return r.content

class Tester:
	err_len = 0
	err_status = 0

	# Check the length of a given array and increment the total of length error in case of inequality
	def check_len(self, array, num, call):
		print("Testint the API call:", call, "   Number of elements expected:", num, " Number of element in array:", len(array))
		if (len(array) != num):
			self.err_len += 1
	
	# Check the status code of the previous request and increment the total of status error in case of inequality
	def check_code(self, exp, res, call):
		print ("Testint the API call:", call, "   Expected status code: ", exp, " Status code returned:", res)
		if (exp != res):
			self.err_status += 1

	# Dump the results of all the test runned by the current Tester
	def dump(self):
		print("Total error for status code:", self.err_status)
		print("Total error for length of resulting JSON:", self.err_len)

if __name__ == '__main__':
	test = Tester()

	admin = RestManager(True)
	admin.signin()
	test.check_code(200, admin.ret_code, "Signin")
	b = json.loads(admin.buildings())
	test.check_code(200, admin.ret_code, "Buildings")
	test.check_len(b, 2, "Buildings")
	t = json.loads(admin.tickets())
	test.check_code(200, admin.ret_code, "Tickets")
	test.check_len(t, 2, "Tickets")

	not_admin = RestManager(False)
	not_admin.signin()
	test.check_code(200, not_admin.ret_code, "Signin")
	b = not_admin.buildings()
	test.check_code(200, not_admin.ret_code, "Buildings")
	test.check_len(b, 1, "Buildings")
	t = not_admin.tickets()
	test.check_code(200, not_admin.ret_code, "Tickets")
	test.check_len(t, 1, "Tickets")

	test.dump()