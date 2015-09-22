expect(response).to include(
  "user" => {
    "email" => be_a(String),
    "name"  => {
      "first_name" => be_a(String),
      "last_name" => be_a(String)
    },
    "age" => be_an(Integer),
    "phone_number" => be_a(String),
    "address" => {
      "country" => {
        "name"  => be_a(String),
        "state"  => {
          "name" => be_a(String),
          "zipcode" => be_a(String)
        }
      }
    }
  }
)

expect(response["user"]["address"]["country"]["state"]["zipcode"]).to match(/^regular-expression$/)
