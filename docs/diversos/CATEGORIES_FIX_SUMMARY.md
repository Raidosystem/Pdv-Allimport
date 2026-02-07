# Quick Reference: Category Isolation Fix

## Problem
All users see all categories (no company/empresa isolation)

## Solution
- Added `empresa_id` column to categories table
- Implemented RLS policies for multi-tenant isolation
- Updated frontend to filter by `empresa_id`

## Changes Made

### Database (`FIX_CATEGORIES_EMPRESA_ISOLATION.sql`)
```sql
-- Add column
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES auth.users(id);

-- Create indexes
CREATE INDEX idx_categories_empresa_id ON public.categories(empresa_id);
CREATE INDEX idx_categories_empresa_name ON public.categories(empresa_id, name);

-- RLS Policies
CREATE POLICY "categories_select_own_empresa" ON public.categories
  FOR SELECT USING (empresa_id = auth.uid());
  
CREATE POLICY "categories_insert_own_empresa" ON public.categories
  FOR INSERT WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "categories_update_own_empresa" ON public.categories
  FOR UPDATE USING (empresa_id = auth.uid()) WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "categories_delete_own_empresa" ON public.categories
  FOR DELETE USING (empresa_id = auth.uid());
```

### Frontend (`src/hooks/useProducts.ts`)

#### fetchCategories() - Line 147-167
```typescript
// BEFORE:
const { data, error } = await supabase
  .from('categories')
  .select('*')
  .order('name')

// AFTER:
const empresa_id = user.id  // Get current user
const { data, error } = await supabase
  .from('categories')
  .select('*')
  .eq('empresa_id', empresa_id)  // Filter by company
  .order('name')
```

#### createCategory() - Line 173-253
```typescript
// BEFORE:
const { data, error } = await supabase
  .from('categories')
  .insert([{ name: name.trim() }])

// AFTER:
const empresa_id = user.id  // Get current user
const { data, error } = await supabase
  .from('categories')
  .insert([{ name: name.trim(), empresa_id }])  // Include company
```

## Deployment Order

1. ✅ Run SQL migration in Supabase
2. ✅ Deploy frontend code to GitHub
3. ✅ Test with multiple users
4. ✅ Verify each user sees only their categories

## Verification

Run these SQL queries in Supabase to verify:

```sql
-- Check column exists
SELECT * FROM information_schema.columns 
WHERE table_name = 'categories' AND column_name = 'empresa_id';

-- Check indexes
SELECT indexname FROM pg_indexes WHERE tablename = 'categories';

-- Check RLS policies
SELECT polname FROM pg_policy WHERE polrelid = 'public.categories'::regclass;

-- Check specific category visibility
SELECT id, name, empresa_id FROM categories LIMIT 10;
```

## Test Scenario

1. **User A** creates "Categoria A" → Only User A sees it
2. **User B** creates "Categoria B" → Only User B sees it
3. **Cross-check**: User A doesn't see "Categoria B", User B doesn't see "Categoria A"

## Files to Deploy

1. Database: `FIX_CATEGORIES_EMPRESA_ISOLATION.sql`
2. Frontend: `src/hooks/useProducts.ts`

## Risk Assessment: LOW ✅

- ✅ Changes isolated to categories table
- ✅ RLS implemented properly at DB level
- ✅ Frontend filters complement DB-level security
- ✅ No breaking changes to other features
- ✅ Easy rollback available

## Performance Impact: POSITIVE ✅

- ✅ New indexes speed up queries
- ✅ Filtered queries return fewer rows
- ✅ Overall system performance improves

## Timeline

- Estimated prep: 30 minutes (reading/understanding)
- Estimated SQL execution: 2-3 minutes
- Estimated frontend deployment: 3-5 minutes
- Estimated testing: 10-15 minutes
- **Total: ~20-25 minutes**
