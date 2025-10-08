# intent-requirements-service/memory_store.py
import os
from dotenv import load_dotenv
load_dotenv()

print("USE_DDB =", os.getenv("USE_DDB"))
print("AWS_DDB_ENDPOINT =", os.getenv("AWS_DDB_ENDPOINT"))
print("AWS_REGION =", os.getenv("AWS_REGION"), "AWS_DEFAULT_REGION =", os.getenv("AWS_DEFAULT_REGION"))
print("DDB_SESSIONS_TABLE =", os.getenv("DDB_SESSIONS_TABLE"))
print("DDB_MEMORY_TABLE =", os.getenv("DDB_MEMORY_TABLE"))

import boto3
from botocore.exceptions import ClientError
from datetime import datetime

DDB_MEMORY_TABLE = os.getenv("DDB_MEMORY_TABLE", "travel_memory")
USE_DDB = os.getenv("USE_DDB", "false").lower() == "true"
AWS_DDB_ENDPOINT = os.getenv("AWS_DDB_ENDPOINT")

# In-memory fallback
_memory_store = {}

if USE_DDB:
    _ddb = boto3.resource(
        "dynamodb",
        region_name=os.getenv("AWS_REGION", "ap-southeast-1"),
        endpoint_url=AWS_DDB_ENDPOINT if AWS_DDB_ENDPOINT else None
    )
    memory_table = _ddb.Table(DDB_MEMORY_TABLE)


def get_memory(session_id: str, target_template: dict = None):
    if not USE_DDB:
        return _memory_store.get(session_id, {
            "session_id": session_id,
            "conversation_history": [],
            "requirements": target_template or {},
            "phase": "initial",
            "last_updated": datetime.now().isoformat()
        })
    try:
        resp = memory_table.get_item(Key={"session_id": session_id})
        if "Item" in resp:
            return resp["Item"]
        # Create default if missing
        return {
            "session_id": session_id,
            "conversation_history": [],
            "requirements": target_template or {},
            "phase": "initial",
            "last_updated": datetime.now().isoformat()
        }
    except ClientError as e:
        print(f"DDB get_memory error: {e}")
        return {
            "session_id": session_id,
            "conversation_history": [],
            "requirements": target_template or {},
            "phase": "initial",
            "last_updated": datetime.now().isoformat()
        }


def put_memory(session_id: str, conversation_history: list, requirements: dict, phase: str):
    item = {
        "session_id": session_id,
        "conversation_history": conversation_history,
        "requirements": requirements,
        "phase": phase,
        "last_updated": datetime.now().isoformat()
    }

    if not USE_DDB:
        _memory_store[session_id] = item
        return

    try:
        memory_table.put_item(Item=item)
    except ClientError as e:
        print(f"DDB put_memory error: {e}")
