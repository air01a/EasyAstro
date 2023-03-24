import csv
from astropy import units as u
from astroplan import FixedTarget
from astropy.table import QTable
from astropy.coordinates import SkyCoord


class Load_Catalog:
    catalog = {}
    _catalog=[]

    def parser_h(self, value):
        tab = value.split(':')
        main_angle = int(tab[0])
        angle = (abs(main_angle) + int(tab[1])/60 + float(tab[2])/3600)
        if tab[0][0]!='+' and tab[0][0]!='-':
            angle = angle * 15
        if tab[0][0]=='-':
            angle = -1 * angle
        return angle

    
    def select_parser(self, parser, value):
        if parser==':':
            return self.parser_h(value)


    def open(self, filename, col_name='NAME', col_ra='RA', col_dec='DEC', parser=':'):
        columns_name=[]
        coord_catalog = []
        with open(filename) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=';')
            line_count = 0
            for row in csv_reader:
                if line_count == 0:
                    columns_name = row
                    line_count += 1
                else:
                    line = {}
                    if len(row)>3:
                        for i in range(0, len(row)):
                            if columns_name[i] == col_ra or columns_name[i] == col_dec:
                                line[columns_name[i]] = self.select_parser(parser, row[i])
                            else:    
                                line[columns_name[i]] = row[i]
                        self.catalog[row[0]]= line
                        line_count += 1
                        coord_catalog.append(FixedTarget(coord=SkyCoord(ra = line[col_ra] * u.deg, dec = line[col_dec]*u.deg),name=line[col_name]))

        self._catalog = coord_catalog



    

        



