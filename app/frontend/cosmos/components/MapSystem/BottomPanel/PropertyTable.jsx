import React, { useState, useMemo } from 'react';
import styles from './PropertyTable.module.css';

export default function PropertyTable({ properties = [], onPropertySelect, searchConditions = {} }) {
  const [sortConfig, setSortConfig] = useState({ key: null, direction: 'asc' });
  const [filters, setFilters] = useState({
    name: '',
    address: '',
    type: '',
    minRooms: '',
    maxRooms: '',
    maxVacancyRate: ''
  });
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 20;

  // サンプルデータ（後でpropsから取得）
  const sampleProperties = [
    {
      id: 1,
      name: 'サンプル物件A',
      address: 'さいたま市浦和区高砂1-1-1',
      type: 'apartment',
      rooms: 25,
      vacantRooms: 3,
      age: 15,
      managementType: 'full'
    },
    {
      id: 2,
      name: 'サンプル物件B',
      address: 'さいたま市大宮区宮町2-2-2',
      type: 'mansion',
      rooms: 45,
      vacantRooms: 7,
      age: 8,
      managementType: 'partial'
    },
    {
      id: 3,
      name: 'サンプル物件C',
      address: 'さいたま市南区文蔵3-3-3',
      type: 'house',
      rooms: 8,
      vacantRooms: 2,
      age: 25,
      managementType: 'none'
    },
    {
      id: 4,
      name: '緑風マンション',
      address: 'さいたま市中央区本町4-4-4',
      type: 'mansion',
      rooms: 32,
      vacantRooms: 5,
      age: 12,
      managementType: 'full'
    },
    {
      id: 5,
      name: '桜ハイツ',
      address: 'さいたま市北区宮原5-5-5',
      type: 'apartment',
      rooms: 18,
      vacantRooms: 1,
      age: 22,
      managementType: 'partial'
    }
  ];

  const allProperties = properties.length > 0 ? properties : sampleProperties;

  // フィルタリング
  const filteredProperties = useMemo(() => {
    return allProperties.filter(property => {
      const vacancyRate = (property.vacantRooms / property.rooms) * 100;
      
      return (
        (!filters.name || property.name.toLowerCase().includes(filters.name.toLowerCase())) &&
        (!filters.address || property.address.toLowerCase().includes(filters.address.toLowerCase())) &&
        (!filters.type || property.type === filters.type) &&
        (!filters.minRooms || property.rooms >= parseInt(filters.minRooms)) &&
        (!filters.maxRooms || property.rooms <= parseInt(filters.maxRooms)) &&
        (!filters.maxVacancyRate || vacancyRate <= parseFloat(filters.maxVacancyRate))
      );
    });
  }, [allProperties, filters]);

  // ソート
  const sortedProperties = useMemo(() => {
    if (!sortConfig.key) return filteredProperties;

    return [...filteredProperties].sort((a, b) => {
      let aValue = a[sortConfig.key];
      let bValue = b[sortConfig.key];

      // 空室率の計算
      if (sortConfig.key === 'vacancyRate') {
        aValue = (a.vacantRooms / a.rooms) * 100;
        bValue = (b.vacantRooms / b.rooms) * 100;
      }

      if (aValue < bValue) {
        return sortConfig.direction === 'asc' ? -1 : 1;
      }
      if (aValue > bValue) {
        return sortConfig.direction === 'asc' ? 1 : -1;
      }
      return 0;
    });
  }, [filteredProperties, sortConfig]);

  // ページネーション
  const paginatedProperties = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    return sortedProperties.slice(startIndex, startIndex + itemsPerPage);
  }, [sortedProperties, currentPage, itemsPerPage]);

  const totalPages = Math.ceil(sortedProperties.length / itemsPerPage);

  const handleSort = (key) => {
    setSortConfig(prevConfig => ({
      key,
      direction: prevConfig.key === key && prevConfig.direction === 'asc' ? 'desc' : 'asc'
    }));
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
    setCurrentPage(1);
  };

  const getSortIcon = (columnKey) => {
    if (sortConfig.key !== columnKey) return '↕️';
    return sortConfig.direction === 'asc' ? '↑' : '↓';
  };

  const getTypeLabel = (type) => {
    const typeMap = {
      apartment: 'アパート',
      mansion: 'マンション',
      house: '戸建て',
      other: 'その他'
    };
    return typeMap[type] || '不明';
  };

  const getManagementTypeLabel = (type) => {
    const typeMap = {
      full: '一括管理',
      partial: '一部管理',
      none: '管理なし'
    };
    return typeMap[type] || '不明';
  };

  const exportToCSV = () => {
    const headers = ['物件名', '住所', '建物種別', '管理方式', '総戸数', '空室数', '空室率(%)', '築年数'];
    const csvData = [
      headers,
      ...sortedProperties.map(property => [
        property.name,
        property.address,
        getTypeLabel(property.type),
        getManagementTypeLabel(property.managementType),
        property.rooms,
        property.vacantRooms,
        ((property.vacantRooms / property.rooms) * 100).toFixed(1),
        property.age
      ])
    ];

    const csvContent = csvData.map(row => row.map(cell => `"${cell}"`).join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = '物件一覧.csv';
    link.click();
  };

  return (
    <div className={styles.tableContainer}>
      <div className={styles.tableHeader}>
        <div className={styles.tableInfo}>
          <span>全{sortedProperties.length}件中 {((currentPage - 1) * itemsPerPage) + 1}～{Math.min(currentPage * itemsPerPage, sortedProperties.length)}件を表示</span>
        </div>
        <div className={styles.tableActions}>
          <button className={styles.exportButton} onClick={exportToCSV}>
            📊 CSV出力
          </button>
        </div>
      </div>

      <div className={styles.tableWrapper}>
        <table className={styles.propertyTable}>
          <thead>
            <tr>
              <th onClick={() => handleSort('name')} className={styles.sortable}>
                物件名 {getSortIcon('name')}
                <input
                  type="text"
                  placeholder="物件名で絞込"
                  value={filters.name}
                  onChange={(e) => handleFilterChange('name', e.target.value)}
                  className={styles.filterInput}
                  onClick={(e) => e.stopPropagation()}
                />
              </th>
              <th onClick={() => handleSort('address')} className={styles.sortable}>
                住所 {getSortIcon('address')}
                <input
                  type="text"
                  placeholder="住所で絞込"
                  value={filters.address}
                  onChange={(e) => handleFilterChange('address', e.target.value)}
                  className={styles.filterInput}
                  onClick={(e) => e.stopPropagation()}
                />
              </th>
              <th onClick={() => handleSort('type')} className={styles.sortable}>
                建物種別 {getSortIcon('type')}
                <select
                  value={filters.type}
                  onChange={(e) => handleFilterChange('type', e.target.value)}
                  className={styles.filterSelect}
                  onClick={(e) => e.stopPropagation()}
                >
                  <option value="">全て</option>
                  <option value="apartment">アパート</option>
                  <option value="mansion">マンション</option>
                  <option value="house">戸建て</option>
                  <option value="other">その他</option>
                </select>
              </th>
              <th onClick={() => handleSort('managementType')} className={styles.sortable}>
                管理方式 {getSortIcon('managementType')}
              </th>
              <th onClick={() => handleSort('rooms')} className={styles.sortable}>
                総戸数 {getSortIcon('rooms')}
                <div className={styles.rangeFilter}>
                  <input
                    type="number"
                    placeholder="最小"
                    value={filters.minRooms}
                    onChange={(e) => handleFilterChange('minRooms', e.target.value)}
                    className={styles.rangeInput}
                    onClick={(e) => e.stopPropagation()}
                  />
                  ～
                  <input
                    type="number"
                    placeholder="最大"
                    value={filters.maxRooms}
                    onChange={(e) => handleFilterChange('maxRooms', e.target.value)}
                    className={styles.rangeInput}
                    onClick={(e) => e.stopPropagation()}
                  />
                </div>
              </th>
              <th onClick={() => handleSort('vacantRooms')} className={styles.sortable}>
                空室数 {getSortIcon('vacantRooms')}
              </th>
              <th onClick={() => handleSort('vacancyRate')} className={styles.sortable}>
                空室率(%) {getSortIcon('vacancyRate')}
                <input
                  type="number"
                  placeholder="最大%"
                  value={filters.maxVacancyRate}
                  onChange={(e) => handleFilterChange('maxVacancyRate', e.target.value)}
                  className={styles.filterInput}
                  onClick={(e) => e.stopPropagation()}
                />
              </th>
              <th onClick={() => handleSort('age')} className={styles.sortable}>
                築年数 {getSortIcon('age')}
              </th>
            </tr>
          </thead>
          <tbody>
            {paginatedProperties.map(property => {
              const vacancyRate = ((property.vacantRooms / property.rooms) * 100).toFixed(1);
              return (
                <tr 
                  key={property.id} 
                  className={styles.tableRow}
                  onClick={() => onPropertySelect && onPropertySelect(property)}
                >
                  <td className={styles.nameCell}>{property.name}</td>
                  <td>{property.address}</td>
                  <td>{getTypeLabel(property.type)}</td>
                  <td>{getManagementTypeLabel(property.managementType)}</td>
                  <td className={styles.numberCell}>{property.rooms}戸</td>
                  <td className={styles.numberCell}>{property.vacantRooms}戸</td>
                  <td className={`${styles.numberCell} ${styles.vacancyRate}`}>
                    <span className={`${styles.vacancyBadge} ${
                      vacancyRate == 0 ? styles.excellent :
                      vacancyRate <= 10 ? styles.good :
                      vacancyRate <= 30 ? styles.warning : styles.danger
                    }`}>
                      {vacancyRate}%
                    </span>
                  </td>
                  <td className={styles.numberCell}>{property.age}年</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className={styles.pagination}>
          <button 
            onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
            disabled={currentPage === 1}
            className={styles.pageButton}
          >
            ← 前へ
          </button>
          
          <div className={styles.pageNumbers}>
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const page = Math.max(1, Math.min(totalPages - 4, currentPage - 2)) + i;
              return (
                <button
                  key={page}
                  onClick={() => setCurrentPage(page)}
                  className={`${styles.pageButton} ${currentPage === page ? styles.active : ''}`}
                >
                  {page}
                </button>
              );
            })}
          </div>

          <button 
            onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
            disabled={currentPage === totalPages}
            className={styles.pageButton}
          >
            次へ →
          </button>
        </div>
      )}
    </div>
  );
}