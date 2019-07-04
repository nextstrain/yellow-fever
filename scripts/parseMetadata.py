import argparse
import csv
from Bio import SeqIO
from treetime.utils import numeric_date
from datetime import datetime
import os

"""
We expect the input CSV files to have these headers:
    "","Sequence_name","Sample_type","Municipality","Host","Host_genus","Host_species","Longitude","Latitude","Municipality_code","Date_collection"
Where sequence name looks like (e.g.) "JF912179|Brazil|GO|Uruacu|MO|Haemagogus||1980"

"""

def parse_args():
    parser = argparse.ArgumentParser(description="Process YFV metadata into a format for analysis with augur")
    parser.add_argument('--metadataIn', metavar='CSV', type=str, nargs="+", required=True, help="input CSV file(s) of YFV metadata")
    parser.add_argument('--sequencesIn', metavar='FASTA', type=str, nargs="+", required=True, help="input FASTA file(s) of YFV sequences")
    parser.add_argument('--metadataOut', metavar='TSV', type=str, required=True, help="output TSV file for augur")
    parser.add_argument('--sequencesOut', metavar='FASTA', type=str, required=True, help="output FASTA file for augur")
    parser.add_argument('--latlongs', metavar='TSV', type=str, required=True, help="output lat/long file for augur")
    return parser.parse_args()

def convert_date_fields_to_numeric(date_fields):
    nXX = date_fields.count("XX")
    if nXX == 0:
      return numeric_date(datetime.strptime("-".join(date_fields), "%Y-%M-%d"))
    elif nXX == 1:
      return numeric_date(datetime.strptime("-".join(date_fields[0:2])+"-15", "%Y-%M-%d"))
    elif nXX == 2:
      return date_fields[0]
    else:
      raise Exception("Unknown date format -- ", date_fields)

def parse_metadata(metadataIn):
    tsv_header = ["strain", "sample_date", "num_date", "collection_year", "sample_type", "country", "municipality", "municipality_code", "host", "host_genus", "host_species", "source_file", "authors"]
    tsv_data = []
    strains = set()
    lat_long_data = {}
    for csv_path in args.metadataIn:
        with open(csv_path, "rU") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                # manually extract strain from sequence name
                strain = row.get("Sequence_name").split("|")[0]
                # country is encoded in the sequence name, not a CSV field (!)
                country = row.get("Sequence_name").split("|")[1]
                # store lat/longs if they are present
                if row.get("Latitude") and row.get("Longitude"):
                    try:
                      lat_long_data[strain] = [float(row.get("Latitude")), float(row.get("Longitude"))]
                    except ValueError:
                      # Non numeric values, e.g. "NA" shouldn't be added to the dictionary
                      pass
                # parse the (sample) date information into the format augur expects:
                # YYYY-MM-DD, with "XX" for missing fields
                date_fields = row.get("Date_collection").split("-")
                if not len(date_fields) or len(date_fields) > 3:
                    print("WARNING: strain {} is missing date information. Skipping".format(strain))
                    continue
                while len(date_fields) != 3:
                    date_fields.append("XX")
                # num_date = numeric_date(datetime.strptime(date.split("-")[0], "YYYY")) if "XX" in date else numeric_date(datetime.strptime(date, "YYYY-MM-DD"))
                # store for export
                strains.add(strain)
                tsv_data.append([
                    strain,
                    "-".join(date_fields),
                    str(convert_date_fields_to_numeric(date_fields)),
                    str(date_fields[0]),
                    row.get("Sample_type"),
                    country,
                    row.get("Municipality"),
                    row.get("Municipality_code"),
                    row.get("Host"),
                    row.get("Host_genus"),
                    row.get("Host_species"),
                    os.path.basename(csv_path),
                    "" # adding a blank authors field stops `augur export` errors
                ])
    return (tsv_header, tsv_data, lat_long_data, strains)

def parse_fasta(fasta_paths, metadata_strains):
    data = []
    for fasta_path in fasta_paths:
        for seq_record in SeqIO.parse(fasta_path, "fasta"):
            # turn 'HM582851|TrinidadAndTobago|NotApplicable|TrinidadAndTobago|NP|Alouatta_seniculus||2009' into "HM582851"
            seq_record.id = seq_record.id.split("|")[0]
            seq_record.description = seq_record.id
            if not seq_record.id in metadata_strains:
                print("WARNING: sequence {} in {} has no metadata in the CSV(s). Skipping.")
                continue
            data.append(seq_record)
    return data



if __name__ == "__main__":
    args = parse_args()
    tsv_header, tsv_data, lat_long_data, strains = parse_metadata(args.metadataIn)
    sequences = parse_fasta(args.sequencesIn, strains)

    ## write out files for augur
    with open(args.metadataOut, "w") as fh:
        print("\t".join(tsv_header), file=fh)
        for row in tsv_data:
            print("\t".join(row), file=fh)

    with open(args.latlongs, "w") as fh:
        for strain, lat_long in lat_long_data.items():
            print("strain\t{}\t{}\t{}".format(strain, lat_long[0], lat_long[1]), file=fh)
    
    SeqIO.write(sequences, args.sequencesOut, "fasta")