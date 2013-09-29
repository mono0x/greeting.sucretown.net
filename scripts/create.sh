#!/bin/sh
createuser puro
createdb -O puro puroland-greeting --locale=C -T template0
