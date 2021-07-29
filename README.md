# Zombie Survival Social Network (ZSSN) API
A Zombie Survival Social Network challenge REST API for the REEV company.

## Architecture
This API uses the N:N (many-to-many) table relationship between items and survivors, making:

1. Easier to add new items.
2. Reduces the amount of data redundancy, which may be a important feature in a zombie apocalypse.

The image below describes the model architecture of the API.

![Model Architecture](/model_arch.png)

## Usage

This API has 3 (three) main sections, made to meet the requirements made in the API specification:

* Survivors
* Reports
* Trade

### Survivor
This main section is responsible to provide the endpoints for survivor related actions.

#### Get all survivors

**Request**

`GET /api/v1/survivors`

**Returns**

A list of all survivors registered in the database.

#### Get a specific survivor

**Request**

`GET /api/v1/survivors/:id`

**Returns**
A specific survivor with the "**:id**" id.

**Checks**
It will be checked if:
* The survivor does exists

#### Create

**Request**

`POST /api/v1/survivors`

**Body**
```json
{
	"name": "Name of the survivor",
	"age": "Age of the survivor",
	"gender": "Survivor's gender",
	"last_pos_latitude": "Last latitude position of the survivor",
	"last_pos_longitude": "Last longitude position of the survivor",
	"inventory": [
		{
			"id": "Id of valid item",
			"item_count": "Amount of item"
		}
	]
}
```

**Returns**
A valid survivor JSON object if created successfully.

**Checks**
It will be checked if:
* There is a inventory parameter
* All the items do exists

#### Flag a survivor
Flag a survivor as infected. At least 3 (three) flags are needed to him actually become considered as infected.

**Request**

`PUT /api/v1/survivors/flag/:id`

**Checks**

It will be checked if:
* Survivor does exists.

#### Update survivor location
Update a specific survivor location.

**Request**

`PUT /api/v1/survivors/update/:id`

**Body**

```json
{
	"last_pos_latitude": "43.5054745",
	"last_pos_longitude": "-23.434394"
}
```

**Checks**

It will be checked if:
* Survivor does exists.

### Reports
Section responsible for statistical reports.

#### Percentage of infected survivors

**Request**

`GET /api/v1/reports/infected`

**Returns**

Percentage of infected survivors which are registered.

#### Percentage of non-infected survivors

**Request**

`GET /api/v1/reports/non-infected`

**Returns**

Percentage of non-infected survivors which are registered.

#### Average amount of a item per survivor

**Request**

`GET /api/v1/reports/average/:item_id`

**Returns**

The average (mean) amount of item (with id = **item_id**) possessed by each survivor.

**Checks**

It will be checked if:
* The **:item_id** item does exists.

#### Points lost because of infected survivor

?

**NOT IMPLEMENTED**

### Trade
Make trades between two survivors.

#### Perform a trade

**Request**

`PUT /api/v1/trade/:trader_id_1/:trader_id_2`

**Body**
```json
{
	"f_items": [
		{
			"id": "valid_item_id",
			"amount": "valid_amount"
		}
	],
	"s_items": [
		{
			"id": "valid_item_id",
			"amount": "valid_amount"
		}
	]
}
```

**Returns**

Whether the trade was successfully made or not.

**Checks**
It will be checked whether if:
* Both traders (survivors) are different.
* Both traders does exists.
* Both traders are infected.
* The items in the sets exists.
* The items in the sets are actually owned by the respective trader (survivor).
* The trader has the least amount of the item proclaimed in the trade.
* There is a repeated item id.
* Both sets are equal in value.

## Tests

The tests in this API were made using RSpec.

To run the automated tests:
`bundle exec rspec`
