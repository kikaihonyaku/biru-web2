import React, { useState, useMemo } from 'react';
import {
  Box,
  Button,
  Chip,
  Typography,
  IconButton,
  Toolbar,
} from '@mui/material';
import {
  DataGrid,
  GridToolbarContainer,
  GridToolbarExport,
  GridToolbarFilterButton,
  GridToolbarColumnsButton,
  GridToolbarDensitySelector,
} from '@mui/x-data-grid';
import {
  FileDownload as FileDownloadIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material';

export default function PropertyTable({ properties = [], onPropertySelect, searchConditions = {} }) {
  const [pageSize, setPageSize] = useState(25);
  const [selectionModel, setSelectionModel] = useState([]);

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

  // DataGrid用の列定義
  const columns = [
    {
      field: 'name',
      headerName: '物件名',
      width: 200,
      flex: 1,
      minWidth: 150,
    },
    {
      field: 'address',
      headerName: '住所',
      width: 250,
      flex: 1,
      minWidth: 200,
    },
    {
      field: 'type',
      headerName: '建物種別',
      width: 120,
      renderCell: (params) => (
        <Chip
          label={getTypeLabel(params.value)}
          size="small"
          color="primary"
          variant="outlined"
        />
      ),
    },
    {
      field: 'managementType',
      headerName: '管理方式',
      width: 120,
      renderCell: (params) => getManagementTypeLabel(params.value),
    },
    {
      field: 'rooms',
      headerName: '総戸数',
      width: 100,
      type: 'number',
      align: 'center',
      headerAlign: 'center',
      renderCell: (params) => `${params.value}戸`,
    },
    {
      field: 'vacantRooms',
      headerName: '空室数',
      width: 100,
      type: 'number',
      align: 'center',
      headerAlign: 'center',
      renderCell: (params) => `${params.value}戸`,
    },
    {
      field: 'vacancyRate',
      headerName: '空室率(%)',
      width: 120,
      type: 'number',
      align: 'center',
      headerAlign: 'center',
      valueGetter: (value, row) => {
        return ((row.vacantRooms / row.rooms) * 100).toFixed(1);
      },
      renderCell: (params) => {
        const rate = parseFloat(params.value);
        let color = 'default';
        if (rate === 0) color = 'success';
        else if (rate <= 10) color = 'info';
        else if (rate <= 30) color = 'warning';
        else color = 'error';

        return (
          <Chip
            label={`${rate}%`}
            size="small"
            color={color}
            sx={{ minWidth: 60 }}
          />
        );
      },
    },
    {
      field: 'age',
      headerName: '築年数',
      width: 100,
      type: 'number',
      align: 'center',
      headerAlign: 'center',
      renderCell: (params) => `${params.value}年`,
    },
  ];

  // データにidフィールドを追加（DataGridで必要）
  const rowsWithId = useMemo(() => {
    return allProperties.map((property) => ({
      ...property,
      id: property.id || Math.random(), // idが無い場合は一意のidを生成
    }));
  }, [allProperties]);

  // カスタムツールバー
  const CustomToolbar = () => {
    return (
      <GridToolbarContainer>
        <GridToolbarColumnsButton />
        <GridToolbarFilterButton />
        <GridToolbarDensitySelector />
        <GridToolbarExport 
          printOptions={{ disableToolbarButton: true }}
          csvOptions={{
            fileName: '物件一覧',
            utf8WithBom: true,
          }}
        />
        <Box sx={{ flexGrow: 1 }} />
        <IconButton
          size="small"
          onClick={() => {
            // リフレッシュ処理（必要に応じて実装）
            console.log('データを更新');
          }}
          sx={{ mr: 1 }}
        >
          <RefreshIcon />
        </IconButton>
      </GridToolbarContainer>
    );
  };

  // 行クリック処理
  const handleRowClick = (params) => {
    if (onPropertySelect) {
      onPropertySelect(params.row);
    }
  };

  return (
    <Box sx={{ height: '100%', width: '100%' }}>
      <DataGrid
        rows={rowsWithId}
        columns={columns}
        pageSize={pageSize}
        onPageSizeChange={(newPageSize) => setPageSize(newPageSize)}
        rowsPerPageOptions={[10, 25, 50, 100]}
        pagination
        checkboxSelection
        disableSelectionOnClick={false}
        onRowClick={handleRowClick}
        selectionModel={selectionModel}
        onSelectionModelChange={(newSelectionModel) => {
          setSelectionModel(newSelectionModel);
        }}
        components={{
          Toolbar: CustomToolbar,
        }}
        sx={{
          border: 'none',
          '& .MuiDataGrid-row': {
            cursor: 'pointer',
          },
        }}
        localeText={{
          // 日本語ローカライゼーション
          noRowsLabel: 'データがありません',
          noResultsOverlayLabel: '検索結果がありません',
          errorOverlayDefaultLabel: 'エラーが発生しました',
          toolbarColumns: '列',
          toolbarFilters: 'フィルター',
          toolbarDensity: '密度',
          toolbarExport: 'エクスポート',
          toolbarExportLabel: 'エクスポート',
          toolbarExportCSV: 'CSVダウンロード',
          toolbarExportPrint: '印刷',
          columnsPanelTextFieldLabel: '列を検索',
          columnsPanelTextFieldPlaceholder: '列名',
          columnsPanelDragIconLabel: '列の順序を変更',
          columnsPanelShowAllButton: '全て表示',
          columnsPanelHideAllButton: '全て隠す',
          filterPanelAddFilter: 'フィルターを追加',
          filterPanelDeleteIconLabel: '削除',
          filterPanelLinkOperator: '論理演算子',
          filterPanelOperator: '演算子',
          filterPanelOperatorAnd: 'かつ',
          filterPanelOperatorOr: 'または',
          filterPanelColumns: '列',
          filterPanelInputLabel: '値',
          filterPanelInputPlaceholder: 'フィルター値',
          filterOperatorContains: '含む',
          filterOperatorEquals: '等しい',
          filterOperatorStartsWith: '始まる',
          filterOperatorEndsWith: '終わる',
          filterOperatorIs: 'である',
          filterOperatorNot: '以外',
          filterOperatorAfter: 'より後',
          filterOperatorOnOrAfter: '以降',
          filterOperatorBefore: 'より前',
          filterOperatorOnOrBefore: '以前',
          filterOperatorIsEmpty: '空である',
          filterOperatorIsNotEmpty: '空でない',
          filterOperatorIsAnyOf: 'のいずれか',
          columnMenuLabel: 'メニュー',
          columnMenuShowColumns: '列を表示',
          columnMenuFilter: 'フィルター',
          columnMenuHideColumn: '列を隠す',
          columnMenuUnsort: 'ソート解除',
          columnMenuSortAsc: '昇順ソート',
          columnMenuSortDesc: '降順ソート',
          columnHeaderFiltersTooltipActive: (count) =>
            count !== 1 ? `${count} active filters` : `${count} active filter`,
          columnHeaderFiltersLabel: 'フィルターを表示',
          columnHeaderSortIconLabel: 'ソート',
          footerRowSelected: (count) =>
            count !== 1
              ? `${count.toLocaleString()} 行を選択中`
              : `${count.toLocaleString()} 行を選択中`,
          footerTotalRows: '総行数:',
          footerTotalVisibleRows: (visibleCount, totalCount) =>
            `${visibleCount.toLocaleString()} / ${totalCount.toLocaleString()}`,
          checkboxSelectionHeaderName: '選択',
          booleanCellTrueLabel: 'はい',
          booleanCellFalseLabel: 'いいえ',
        }}
      />
    </Box>
  );
}