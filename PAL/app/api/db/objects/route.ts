import { NextResponse } from 'next/server'
import { getPool } from '../../../../lib/db'

function mapType(t: string) {
  if (t === 'P') return 'Stored Procedure'
  if (t === 'FN') return 'Scalar Function'
  if (t === 'TF') return 'Table Function'
  if (t === 'IF') return 'Inline Table Function'
  return t
}

export async function GET() {
  const pool = await getPool()
  try {
    const result = await pool.request().query(`
      SELECT 
        s.name AS schemaName,
        o.name AS objectName,
        o.type AS objectType,
        sm.definition AS definition,
        o.create_date AS createDate,
        o.modify_date AS modifyDate,
        STRING_AGG(CONCAT(p.name,' ',TYPE_NAME(p.user_type_id),' ',CASE WHEN p.is_output=1 THEN 'OUTPUT' ELSE '' END), ', ') 
          WITHIN GROUP (ORDER BY p.parameter_id) AS parameters
      FROM sys.objects o
      JOIN sys.schemas s ON s.schema_id = o.schema_id
      LEFT JOIN sys.sql_modules sm ON sm.object_id = o.object_id
      LEFT JOIN sys.parameters p ON p.object_id = o.object_id
      WHERE o.type IN ('P','FN','TF','IF')
      GROUP BY s.name, o.name, o.type, sm.definition, o.create_date, o.modify_date
      ORDER BY s.name, o.name
    `)
    const items = result.recordset.map((r: any) => ({
      schema: r.schemaName,
      name: r.objectName,
      type: mapType(r.objectType),
      createdAt: r.createDate,
      modifiedAt: r.modifyDate,
      parameters: r.parameters || '',
      definition: r.definition || ''
    }))
    return NextResponse.json({ count: items.length, items }, { status: 200 })
  } catch (e) {
    const fallback = await pool.request().query(`
      SELECT 
        s.name AS schemaName,
        o.name AS objectName,
        o.type AS objectType,
        sm.definition AS definition,
        o.create_date AS createDate,
        o.modify_date AS modifyDate
      FROM sys.objects o
      JOIN sys.schemas s ON s.schema_id = o.schema_id
      LEFT JOIN sys.sql_modules sm ON sm.object_id = o.object_id
      WHERE o.type IN ('P','FN','TF','IF')
      ORDER BY s.name, o.name
    `)
    const items = fallback.recordset.map((r: any) => ({
      schema: r.schemaName,
      name: r.objectName,
      type: mapType(r.objectType),
      createdAt: r.createDate,
      modifiedAt: r.modifyDate,
      parameters: '',
      definition: r.definition || ''
    }))
    return NextResponse.json({ count: items.length, items, note: 'parameters omitted (fallback)' }, { status: 200 })
  }
}
